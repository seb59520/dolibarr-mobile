import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:flutter/foundation.dart';

/// Résultat typé d'une opération qui peut échouer.
///
/// Patron équivalent à `Either<Failure, T>` mais ergonomique côté Dart 3.
/// Toute la couche `data` retourne un `Result<T>` pour bannir les `throw`
/// non maîtrisés au-delà de la frontière `data → domain`.
sealed class Result<T> {
  const Result();

  /// Vrai si le résultat est un succès.
  bool get isSuccess => this is Success<T>;

  /// Vrai si le résultat est un échec.
  bool get isFailure => this is FailureResult<T>;

  /// Récupère la valeur ou retourne [orElse] si échec.
  T getOrElse(T Function(Failure) orElse) => switch (this) {
        Success<T>(value: final v) => v,
        FailureResult<T>(failure: final f) => orElse(f),
      };

  /// Transforme la valeur en cas de succès, propage l'échec sinon.
  Result<R> map<R>(R Function(T) transform) => switch (this) {
        Success<T>(value: final v) => Success<R>(transform(v)),
        FailureResult<T>(failure: final f) => FailureResult<R>(f),
      };

  /// Chaîne deux opérations dépendantes (monadique).
  Result<R> flatMap<R>(Result<R> Function(T) transform) => switch (this) {
        Success<T>(value: final v) => transform(v),
        FailureResult<T>(failure: final f) => FailureResult<R>(f),
      };

  /// Pattern-matching exhaustif côté présentation.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(value: final v) => onSuccess(v),
        FailureResult<T>(failure: final f) => onFailure(f),
      };
}

/// Variante succès.
@immutable
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      other is Success<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Variante échec — porte un [Failure] décrit.
@immutable
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is FailureResult<T> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'FailureResult($failure)';
}
