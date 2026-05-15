import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/ocr_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/extracted_ticket.dart';

/// Surcharges saisies manuellement par l'utilisateur dans le formulaire
/// après l'OCR. Tous les champs sont optionnels — quand `null`, on
/// retombe sur la valeur extraite (ou un défaut sensé).
final class ExpenseTicketOverrides {
  const ExpenseTicketOverrides({
    this.merchant,
    this.date,
    this.amountTtc,
    this.vatRate,
    this.feeTypeId,
    this.feeTypeCode,
    this.comments,
    this.projectId,
  });

  final String? merchant;
  final DateTime? date;
  final double? amountTtc;

  /// Taux TVA en pourcentage (ex. `20`).
  final double? vatRate;

  /// `llx_c_type_fees.id` choisi par l'utilisateur (ou inféré depuis le
  /// code suggéré par l'OCR).
  final int? feeTypeId;

  /// Code textuel correspondant (utile pour les logs et `comments`).
  final String? feeTypeCode;

  /// Notes libres ajoutées par l'utilisateur. Remplace le texte généré
  /// automatiquement à partir de `merchant` / `rawText`.
  final String? comments;

  /// Projet Dolibarr d'affectation (optionnel).
  final int? projectId;
}

/// Résultat du push d'un ticket : on remonte juste les identifiants
/// Dolibarr pertinents pour que l'UI puisse rediriger vers la fiche.
final class TicketPushOutcome {
  const TicketPushOutcome({
    required this.reportRemoteId,
    required this.reportRef,
    required this.lineRemoteId,
    required this.documentUploaded,
  });

  final int reportRemoteId;
  final String reportRef;
  final int lineRemoteId;
  final bool documentUploaded;
}

/// Récupère l'`id` Dolibarr de l'utilisateur courant. Implémentée par un
/// wrapper Riverpod côté `expense_providers.dart` qui lit
/// `authNotifierProvider`.
typedef CurrentUserIdResolver = int Function();

/// Récupère le mapping `code → id` pour `c_type_fees`. Le pipeline en a
/// besoin pour transformer un `SuggestedFeeTypeCode` en `fk_c_type_fees`.
typedef FeeTypeResolver = Future<int?> Function(String code);

/// Orchestrateur scan → push d'un ticket de caisse.
///
/// Étapes :
///   1. OCR via [OcrRemoteDataSource]
///   2. Lookup d'une note de frais brouillon existante de l'utilisateur,
///      sinon création d'une nouvelle (date_debut = date_fin = date
///      du ticket).
///   3. Ajout d'une ligne (POST `/expensereports/<id>/line` singulier).
///   4. Upload du JPEG dans l'ECM lié.
///
/// Toute exception est captée et remontée en `Result<…>` avec un
/// [Failure] typé — l'UI affiche directement `failure.toString()`.
final class ExpenseTicketPipeline {
  ExpenseTicketPipeline({
    required OcrRemoteDataSource ocr,
    required ExpenseRemoteDataSource remote,
    required NetworkInfo network,
    required CurrentUserIdResolver currentUserId,
    required FeeTypeResolver resolveFeeType,
  })  : _ocr = ocr,
        _remote = remote,
        _network = network,
        _currentUserId = currentUserId,
        _resolveFeeType = resolveFeeType;

  final OcrRemoteDataSource _ocr;
  final ExpenseRemoteDataSource _remote;
  final NetworkInfo _network;
  final CurrentUserIdResolver _currentUserId;
  final FeeTypeResolver _resolveFeeType;

  /// Lance l'OCR sur l'image fournie et renvoie le DTO extrait sans
  /// rien pousser. Permet de proposer un formulaire éditable avant de
  /// commettre côté Dolibarr.
  Future<Result<ExtractedTicketDto>> extract({
    required Uint8List jpegBytes,
    required String endpoint,
    required String bearer,
  }) async {
    if (!_network.isOnline) {
      return const FailureResult(
        NetworkFailure(
          message: 'Scanner indisponible hors-ligne — '
              'l’OCR nécessite le backend.',
        ),
      );
    }
    if (bearer.trim().isEmpty) {
      return const FailureResult(
        OcrFailure(
          message: 'Jeton OCR manquant. Configurez-le dans Paramètres.',
        ),
      );
    }
    try {
      final dto = await _ocr.extractTicket(
        jpegBytes: jpegBytes,
        endpoint: endpoint,
        bearer: bearer,
      );
      return Success(dto);
    } on DioException catch (e) {
      return FailureResult(mapDioToOcrFailure(e, fallbackEndpoint: endpoint));
    } on OcrException catch (e) {
      return FailureResult(OcrFailure(message: e.message));
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  /// Push d'une ligne de note de frais finale. Accepte directement les
  /// overrides utilisateur car l'UI a déjà fait merger l'OCR avec le
  /// formulaire (champs éditables).
  ///
  /// [jpegBytes] sert UNIQUEMENT à l'upload final dans l'ECM. Si null,
  /// on saute proprement l'étape document.
  Future<Result<TicketPushOutcome>> push({
    required ExpenseTicketOverrides overrides,
    Uint8List? jpegBytes,
    String filename = 'ticket.jpg',
  }) async {
    if (!_network.isOnline) {
      return const FailureResult(
        NetworkFailure(
          message: 'Connexion requise pour pousser la note de frais.',
        ),
      );
    }

    final ticketDate = overrides.date ?? DateTime.now();
    final ttc = overrides.amountTtc;
    if (ttc == null || ttc <= 0) {
      return const FailureResult(
        ValidationFailure(
          message: 'Montant TTC obligatoire pour créer la ligne.',
        ),
      );
    }

    int feeTypeId;
    if (overrides.feeTypeId != null && overrides.feeTypeId! > 0) {
      feeTypeId = overrides.feeTypeId!;
    } else if (overrides.feeTypeCode != null &&
        overrides.feeTypeCode!.isNotEmpty) {
      final resolved = await _resolveFeeType(overrides.feeTypeCode!);
      if (resolved == null || resolved <= 0) {
        return FailureResult<TicketPushOutcome>(
          ValidationFailure(
            message: 'Type de frais inconnu côté Dolibarr : '
                '${overrides.feeTypeCode}.',
          ),
        );
      }
      feeTypeId = resolved;
    } else {
      return const FailureResult<TicketPushOutcome>(
        ValidationFailure(
          message: 'Type de frais obligatoire pour créer la ligne.',
        ),
      );
    }

    final int userId;
    try {
      userId = _currentUserId();
    } catch (e) {
      return FailureResult<TicketPushOutcome>(
        UnauthorizedFailure(
          message: 'Session utilisateur introuvable : $e',
        ),
      );
    }

    try {
      // 2. Cherche une note brouillon existante.
      final draft = await _findDraftReport(userId: userId);
      final reportRemoteId =
          draft != null ? _idOf(draft) : await _createDraftReport(
                userId: userId,
                date: ticketDate,
              );

      // Re-fetch le détail pour récupérer la `ref` (`ND2026-…`) requise
      // par l'upload ECM (`modulepart=expensereport&ref=…`).
      final detail = await _remote.fetchById(reportRemoteId);
      final ref = (detail['ref'] ?? '').toString();
      if (ref.isEmpty) {
        return FailureResult<TicketPushOutcome>(
          ServerFailure(
            message: 'Note de frais $reportRemoteId créée sans ref.',
          ),
        );
      }

      // 3. Ajout de la ligne.
      final tva = overrides.vatRate ?? 0;
      final valueUnit = ttc.toString();
      final lineRemoteId = await _remote.createLine(reportRemoteId, {
        'fk_c_type_fees': feeTypeId,
        'date': ticketDate.millisecondsSinceEpoch ~/ 1000,
        'qty': 1,
        'value_unit': valueUnit,
        'vatrate': tva.toString(),
        'comments': _buildComments(overrides),
        if (overrides.projectId != null) 'fk_project': overrides.projectId,
      });

      // 4. Upload du justificatif (best-effort — n'échoue pas tout le
      // pipeline si l'ECM refuse, on remonte juste documentUploaded=false).
      var uploaded = false;
      if (jpegBytes != null && jpegBytes.isNotEmpty) {
        try {
          await _remote.uploadDocument(
            ref: ref,
            filename: filename,
            base64Content: base64Encode(jpegBytes),
          );
          uploaded = true;
        } on Exception {
          uploaded = false;
        }
      }

      return Success(
        TicketPushOutcome(
          reportRemoteId: reportRemoteId,
          reportRef: ref,
          lineRemoteId: lineRemoteId,
          documentUploaded: uploaded,
        ),
      );
    } on UnauthorizedException catch (e) {
      return FailureResult<TicketPushOutcome>(
        UnauthorizedFailure(message: e.message),
      );
    } on ValidationException catch (e) {
      return FailureResult<TicketPushOutcome>(
        ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on ServerException catch (e) {
      return FailureResult<TicketPushOutcome>(
        ServerFailure(
          statusCode: e.statusCode,
          message: e.message,
        ),
      );
    } on NetworkException catch (e) {
      return FailureResult<TicketPushOutcome>(
        NetworkFailure(message: e.message),
      );
    } catch (e, st) {
      return FailureResult<TicketPushOutcome>(ErrorMapper.toFailure(e, st));
    }
  }

  // ---------------- Helpers ------------------------------------------

  Future<Map<String, Object?>?> _findDraftReport({required int userId}) async {
    // sqlfilters côté `/expensereports` : `fk_statut=0` + `fk_user_author`.
    // On laisse le tri descendant sur `date_debut` (cf. fetchPage par
    // défaut) puis on prend le premier hit qui matche.
    final filters = ExpenseFilters(
      fkUserAuthor: userId,
      statuses: const {ExpenseReportStatus.draft},
    );
    final rows = await _remote.fetchPage(
      filters: filters,
      page: 0,
      limit: 50,
    );
    for (final r in rows) {
      final status = int.tryParse('${r['status'] ?? r['fk_statut'] ?? ''}');
      final author = int.tryParse('${r['fk_user_author'] ?? ''}');
      if (status == 0 && author == userId) {
        return r;
      }
    }
    return null;
  }

  Future<int> _createDraftReport({
    required int userId,
    required DateTime date,
  }) async {
    final ts = date.millisecondsSinceEpoch ~/ 1000;
    return _remote.create(<String, Object?>{
      'fk_user_author': userId,
      'fk_user_valid': userId,
      'date_debut': ts,
      'date_fin': ts,
    });
  }

  int _idOf(Map<String, Object?> json) {
    final v = json['id'] ?? json['rowid'];
    final n = int.tryParse('$v');
    if (n == null) {
      throw const ServerException(
        statusCode: 200,
        message: 'Note de frais existante sans `id` exploitable.',
      );
    }
    return n;
  }

  String _buildComments(ExpenseTicketOverrides o) {
    if (o.comments != null && o.comments!.trim().isNotEmpty) {
      return o.comments!.trim();
    }
    final merchant = (o.merchant ?? '').trim();
    if (merchant.isNotEmpty) return merchant;
    return 'Ticket scanné';
  }
}
