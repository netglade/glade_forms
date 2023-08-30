import 'package:equatable/equatable.dart';

typedef OnConvertError = String Function(String? rawInput, Object? extra);

class ConvertError<T> extends Equatable implements Exception {
  final OnConvertError devError;

  // ignore: avoid-dynamic, allow dynamic for now
  final dynamic error;

  final String? rawValue;

  @override
  List<Object?> get props => [rawValue, devError, error];

  String get targetType => T.runtimeType.toString();

  ConvertError({
    required this.error,
    required this.rawValue,
    OnConvertError? onError,
  }) : devError = onError ?? ((rawValue, extra) => 'Value "$rawValue" does not have valid format. Error: $error');

  @override
  String toString() => devError(rawValue, error);
}
