import 'dart:io';

import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/features/expenses/data/expense_ticket_pipeline.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/extracted_ticket.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/expense_providers.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/ocr_providers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Phase courante de la machine à états du scan.
enum ExpenseScanPhase {
  idle,
  capturing,
  extracting,
  editing,
  pushing,
  done,
  error,
}

/// État immuable de la machine — exposé via Riverpod pour piloter l'UI
/// (spinner, formulaire, bouton "Enregistrer", etc.).
final class ExpenseScanState extends Equatable {
  const ExpenseScanState({
    this.phase = ExpenseScanPhase.idle,
    this.jpegBytes,
    this.extracted,
    this.failure,
    this.outcome,
    this.manualEntry = false,
  });

  final ExpenseScanPhase phase;
  final Uint8List? jpegBytes;
  final ExtractedTicketDto? extracted;
  final Failure? failure;
  final TicketPushOutcome? outcome;

  /// Vrai si l'utilisateur a choisi "Saisir manuellement" : on saute
  /// l'étape OCR et on présente directement le formulaire vierge.
  final bool manualEntry;

  ExpenseScanState copyWith({
    ExpenseScanPhase? phase,
    Uint8List? jpegBytes,
    ExtractedTicketDto? extracted,
    Failure? failure,
    TicketPushOutcome? outcome,
    bool? manualEntry,
    bool clearFailure = false,
    bool clearExtracted = false,
    bool clearJpeg = false,
  }) =>
      ExpenseScanState(
        phase: phase ?? this.phase,
        jpegBytes: clearJpeg ? null : (jpegBytes ?? this.jpegBytes),
        extracted: clearExtracted ? null : (extracted ?? this.extracted),
        failure: clearFailure ? null : (failure ?? this.failure),
        outcome: outcome ?? this.outcome,
        manualEntry: manualEntry ?? this.manualEntry,
      );

  @override
  List<Object?> get props => [
        phase,
        // Identité par taille pour ne pas DeepCompare l'image entière.
        jpegBytes?.length ?? 0,
        extracted,
        failure,
        outcome,
        manualEntry,
      ];
}

/// Compression image plug-in : sortable pour tests (skip compression).
typedef ImageCompressor = Future<Uint8List?> Function(Uint8List input);

Future<Uint8List?> _defaultCompress(Uint8List input) async {
  return FlutterImageCompress.compressWithList(
    input,
    minWidth: 1600,
    minHeight: 1600,
    quality: 80,
  );
}

/// Contrôleur du flux scan → OCR → push.
///
/// API :
///   - [pickAndExtract] : capture + appel backend, puis état `editing`.
///   - [startManual] : passe en `editing` avec formulaire vierge.
///   - [push] : commit final → état `done` ou `error`.
///   - [reset] : revient à `idle`.
class ExpenseScanController extends Notifier<ExpenseScanState> {
  ExpenseScanController({
    ImagePicker? picker,
    ImageCompressor? compressor,
  })  : _pickerOverride = picker,
        _compressorOverride = compressor;

  final ImagePicker? _pickerOverride;
  final ImageCompressor? _compressorOverride;

  ImagePicker get _picker => _pickerOverride ?? ImagePicker();
  ImageCompressor get _compress => _compressorOverride ?? _defaultCompress;

  static const int _maxBytes = 15 * 1024 * 1024;

  @override
  ExpenseScanState build() => const ExpenseScanState();

  /// Lance la capture (caméra ou galerie selon [source]) + l'appel OCR.
  Future<void> pickAndExtract(ImageSource source) async {
    state = state.copyWith(
      phase: ExpenseScanPhase.capturing,
      clearFailure: true,
      clearExtracted: true,
      clearJpeg: true,
    );

    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: source,
        maxWidth: 3200,
        imageQuality: 90,
      );
    } catch (e) {
      state = state.copyWith(
        phase: ExpenseScanPhase.error,
        failure: UnknownFailure(message: 'Capture impossible : $e'),
      );
      return;
    }

    if (file == null) {
      // Annulé par l'utilisateur — retour à idle sans erreur.
      state = state.copyWith(phase: ExpenseScanPhase.idle);
      return;
    }

    final rawBytes = await File(file.path).readAsBytes();
    Uint8List jpeg;
    try {
      final compressed = await _compress(rawBytes);
      jpeg = compressed ?? rawBytes;
    } catch (_) {
      jpeg = rawBytes;
    }

    if (jpeg.length > _maxBytes) {
      state = state.copyWith(
        phase: ExpenseScanPhase.error,
        failure: const ValidationFailure(
          message: 'Image trop volumineuse même après compression (>15 Mo).',
        ),
      );
      return;
    }

    state = state.copyWith(
      phase: ExpenseScanPhase.extracting,
      jpegBytes: jpeg,
    );

    final endpoint =
        ref.read(ocrEndpointProvider).valueOrNull ?? kDefaultOcrEndpoint;
    final bearer = ref.read(ocrBearerProvider).valueOrNull ?? '';

    final pipeline = ref.read(expenseTicketPipelineProvider);
    final result = await pipeline.extract(
      jpegBytes: jpeg,
      endpoint: endpoint,
      bearer: bearer,
    );
    result.fold(
      onSuccess: (dto) {
        state = state.copyWith(
          phase: ExpenseScanPhase.editing,
          extracted: dto,
        );
      },
      onFailure: (f) {
        state = state.copyWith(phase: ExpenseScanPhase.error, failure: f);
      },
    );
  }

  /// Mode manuel : pas d'image, pas d'OCR, on va direct au formulaire.
  void startManual() {
    state = state.copyWith(
      phase: ExpenseScanPhase.editing,
      manualEntry: true,
      clearFailure: true,
      clearExtracted: true,
      clearJpeg: true,
    );
  }

  /// Pousse l'expense report. Renvoie le `Result` pour que l'UI puisse
  /// faire un snack + navigation à la complétion.
  Future<TicketPushOutcome?> push(ExpenseTicketOverrides overrides) async {
    state = state.copyWith(
      phase: ExpenseScanPhase.pushing,
      clearFailure: true,
    );
    final pipeline = ref.read(expenseTicketPipelineProvider);
    final result = await pipeline.push(
      overrides: overrides,
      jpegBytes: state.jpegBytes,
    );
    final outcome = result.fold(
      onSuccess: (o) {
        state = state.copyWith(phase: ExpenseScanPhase.done, outcome: o);
        return o;
      },
      onFailure: (f) {
        state = state.copyWith(phase: ExpenseScanPhase.error, failure: f);
        return null;
      },
    );
    return outcome;
  }

  void reset() {
    state = const ExpenseScanState();
  }

  /// Test-only : injecter une image déjà préparée + un DTO simulé pour
  /// court-circuiter `pickAndExtract` dans les widget tests.
  @visibleForTesting
  void seedForTest({
    Uint8List? jpegBytes,
    ExtractedTicketDto? extracted,
    ExpenseScanPhase phase = ExpenseScanPhase.editing,
  }) {
    state = state.copyWith(
      phase: phase,
      jpegBytes: jpegBytes,
      extracted: extracted,
    );
  }
}

final expenseScanControllerProvider =
    NotifierProvider<ExpenseScanController, ExpenseScanState>(
  ExpenseScanController.new,
);
