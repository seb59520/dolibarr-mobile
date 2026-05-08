import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioWith({
  int? status,
  Object? data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final req = RequestOptions(path: '/test');
  return DioException(
    requestOptions: req,
    type: type,
    response: Response<Object?>(
      requestOptions: req,
      statusCode: status,
      data: data,
    ),
  );
}

void main() {
  group('ErrorMapper.fromDio', () {
    test('timeout → NetworkException', () {
      final e = ErrorMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(e, isA<NetworkException>());
    });

    test('connection error → NetworkException', () {
      final e = ErrorMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(e, isA<NetworkException>());
    });

    test('401 → UnauthorizedException', () {
      final e = ErrorMapper.fromDio(_dioWith(status: 401));
      expect(e, isA<UnauthorizedException>());
    });

    test('403 → ForbiddenException', () {
      final e = ErrorMapper.fromDio(_dioWith(status: 403));
      expect(e, isA<ForbiddenException>());
    });

    test('404 → NotFoundException', () {
      final e = ErrorMapper.fromDio(_dioWith(status: 404));
      expect(e, isA<NotFoundException>());
    });

    test('400 → ValidationException', () {
      final e = ErrorMapper.fromDio(_dioWith(status: 400));
      expect(e, isA<ValidationException>());
    });

    test('500 → ServerException avec statusCode', () {
      final e =
          ErrorMapper.fromDio(_dioWith(status: 500)) as ServerException;
      expect(e.statusCode, 500);
    });

    test('extrait message depuis data.error.message', () {
      final e = ErrorMapper.fromDio(
        _dioWith(
          status: 400,
          data: <String, Object?>{
            'error': <String, Object?>{'message': 'Champs invalides'},
          },
        ),
      ) as ValidationException;
      expect(e.message, 'Champs invalides');
    });
  });

  group('ErrorMapper.toFailure', () {
    test('UnauthorizedException → UnauthorizedFailure', () {
      final f = ErrorMapper.toFailure(const UnauthorizedException('expired'));
      expect(f, isA<UnauthorizedFailure>());
      expect(f.message, 'expired');
    });

    test('ServerException → ServerFailure préservant statusCode', () {
      final f = ErrorMapper.toFailure(
        const ServerException(statusCode: 503, message: 'down'),
      );
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).statusCode, 503);
    });

    test('ValidationException → ValidationFailure préservant fieldErrors', () {
      final f = ErrorMapper.toFailure(
        const ValidationException(
          message: 'KO',
          fieldErrors: {'name': 'requis'},
        ),
      );
      expect(f, isA<ValidationFailure>());
      expect((f as ValidationFailure).fieldErrors, {'name': 'requis'});
    });

    test('exception inconnue → UnknownFailure', () {
      final f = ErrorMapper.toFailure(StateError('boom'));
      expect(f, isA<UnknownFailure>());
    });
  });
}
