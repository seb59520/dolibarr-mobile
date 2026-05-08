import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success expose isSuccess et la valeur', () {
      const r = Success<int>(42);
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
      expect(r.getOrElse((_) => 0), 42);
    });

    test('FailureResult expose isFailure et le Failure', () {
      const r = FailureResult<int>(NetworkFailure(message: 'KO'));
      expect(r.isFailure, isTrue);
      expect(r.isSuccess, isFalse);
      expect(r.getOrElse((f) => -1), -1);
    });

    test('map transforme la valeur en cas de succès', () {
      const r = Success<int>(10);
      final mapped = r.map((v) => v * 2);
      expect(mapped, const Success<int>(20));
    });

    test('map propage le Failure inchangé', () {
      const r = FailureResult<int>(UnknownFailure(message: 'oops'));
      final mapped = r.map((v) => v * 2);
      expect(mapped, isA<FailureResult<int>>());
      expect(
        (mapped as FailureResult<int>).failure,
        isA<UnknownFailure>(),
      );
    });

    test('flatMap chaîne deux opérations succès', () {
      const r = Success<int>(3);
      final chained = r.flatMap<String>((v) => Success('val=$v'));
      expect(chained, const Success<String>('val=3'));
    });

    test('flatMap court-circuite sur le premier échec', () {
      const r = FailureResult<int>(NetworkFailure());
      final chained = r.flatMap<String>(
        (v) => Success('jamais=$v'),
      );
      expect(chained, isA<FailureResult<String>>());
    });

    test('fold appelle onSuccess pour Success', () {
      const r = Success<int>(7);
      final out = r.fold(
        onSuccess: (v) => 'ok-$v',
        onFailure: (f) => 'fail',
      );
      expect(out, 'ok-7');
    });

    test('fold appelle onFailure pour FailureResult', () {
      const r = FailureResult<int>(UnauthorizedFailure());
      final out = r.fold(
        onSuccess: (v) => 'ok',
        onFailure: (f) => 'fail-${f.runtimeType}',
      );
      expect(out, 'fail-UnauthorizedFailure');
    });
  });
}
