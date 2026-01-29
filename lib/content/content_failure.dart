/// Content Load Failure Models
///
/// Used to represent specific failure states when loading content.
sealed class ContentLoadFailure {
  final String unitId;
  ContentLoadFailure(this.unitId);

  factory ContentLoadFailure.notFound(String unitId) = ContentNotFound;
  factory ContentLoadFailure.requiresOnline(String unitId) =
      ContentRequiresOnline;
  factory ContentLoadFailure.corrupted(String unitId, String error) =
      ContentCorrupted;
  factory ContentLoadFailure.unknown(String unitId, String error) =
      ContentUnknown;

  @override
  String toString() {
    return switch (this) {
      ContentNotFound() => 'Unit $unitId not found.',
      ContentRequiresOnline() =>
        'Internet connection required to download $unitId.',
      ContentCorrupted(error: final e) => 'Unit $unitId corrupted: $e',
      ContentUnknown(error: final e) => 'Unknown error loading $unitId: $e',
    };
  }
}

class ContentNotFound extends ContentLoadFailure {
  ContentNotFound(super.unitId);
}

class ContentRequiresOnline extends ContentLoadFailure {
  ContentRequiresOnline(super.unitId);
}

class ContentCorrupted extends ContentLoadFailure {
  final String error;
  ContentCorrupted(super.unitId, this.error);
}

class ContentUnknown extends ContentLoadFailure {
  final String error;
  ContentUnknown(super.unitId, this.error);
}

/// Generic Result wrapper
class Result<V, F> {
  final V? _value;
  final F? _failure;

  Result.success(V value) : _value = value, _failure = null;
  Result.failure(F failure) : _value = null, _failure = failure;

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  V get value {
    if (isFailure) throw StateError('Cannot get value from failure result');
    return _value!;
  }

  F get failure {
    if (isSuccess) throw StateError('Cannot get failure from success result');
    return _failure!;
  }
}
