import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_local_dao.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ExpenseRemoteDataSource {}

class _MockDao extends Mock implements ExpenseLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockOutbox extends Mock implements PendingOperationDao {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ExpenseFilters());
  });

  late _MockRemote remote;
  late _MockDao dao;
  late _MockNetwork network;
  late _MockOutbox outbox;
  late ExpenseRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    dao = _MockDao();
    network = _MockNetwork();
    outbox = _MockOutbox();
    repo = ExpenseRepositoryImpl(
      remote: remote,
      dao: dao,
      network: network,
      outbox: outbox,
    );
  });

  group('refreshPage idempotence', () {
    test(
        'deux refresh consécutifs avec le même payload → '
        'upsertManyFromServer rappelé 2× avec les mêmes données',
        () async {
      final serverRows = [
        const <String, Object?>{
          'id': 42,
          'ref': 'ND2026-0042',
          'fk_statut': 0,
          'date_debut': 1746000000,
          'date_fin': 1746604800,
          'fk_user_author': 5,
          'total_ht': '13.64',
          'total_tva': '1.36',
          'total_ttc': '15.00',
        },
        const <String, Object?>{
          'id': 43,
          'ref': '(PROV43)',
          'fk_statut': 0,
          'date_debut': 1748000000,
          'date_fin': 1748604800,
          'fk_user_author': 5,
        },
      ];

      when(
        () => remote.fetchPage(
          filters: any(named: 'filters'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => serverRows);
      when(() => dao.upsertManyFromServer(any())).thenAnswer((_) async {});

      final first = await repo.refreshPage(
        filters: const ExpenseFilters(),
        page: 0,
      );
      final second = await repo.refreshPage(
        filters: const ExpenseFilters(),
        page: 0,
      );
      expect((first as Success<int>).value, 2);
      expect((second as Success<int>).value, 2);

      // 2 appels effectifs, sans erreur ni doublon (le contrat
      // upsertOnConflictUpdate de Drift assure l'idempotence côté DAO).
      verify(() => dao.upsertManyFromServer(serverRows)).called(2);
    });

    test(
        'refreshTypes deux fois → contrat upsertTypesFromServer'
        ' appelé 2 fois (idempotent côté DAO)', () async {
      final types = [
        const <String, Object?>{
          'id': 3,
          'code': 'TF_LUNCH',
          'label': 'Lunch',
          'active': '1',
        },
        const <String, Object?>{
          'id': 1,
          'code': 'TF_OTHER',
          'label': 'Other',
          'active': '1',
        },
      ];
      when(() => remote.fetchTypes()).thenAnswer((_) async => types);
      when(() => dao.upsertTypesFromServer(any())).thenAnswer((_) async {});

      final a = await repo.refreshTypes();
      final b = await repo.refreshTypes();
      expect((a as Success<int>).value, 2);
      expect((b as Success<int>).value, 2);
      verify(() => dao.upsertTypesFromServer(types)).called(2);
    });
  });
}
