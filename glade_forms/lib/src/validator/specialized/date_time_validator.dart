// ignore_for_file: prefer-single-declaration-per-file

import 'package:glade_forms/src/core/error/error.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:netglade_utils/netglade_utils.dart';

typedef DateTimeValidatorFactory = ValidatorInstance<DateTime> Function(DateTimeValidator validator);
typedef DateTimeValidatorFactoryNullable = ValidatorInstance<DateTime?> Function(DateTimeValidatorNullable validator);

class DateTimeValidator extends GladeValidator<DateTime> {
  /// Compares given value with [start] and [end] values.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// With [includeTime] set to true(default), the comparison includes time.
  ///
  /// Default [key] is [ GladeErrorKeys.dateTimeIsBetweenError].
  void isBetween({
    required DateTime start,
    required DateTime end,
    OnValidate<DateTime>? devError,
    Object? key,
    ShouldValidateCallback<DateTime>? shouldValidate,
    bool inclusiveInterval = true,
    bool includeTime = true,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          final comparedValue = includeTime ? value : value.withoutTime;
          final startValue = includeTime ? start : start.withoutTime;
          final endValue = includeTime ? end : end.withoutTime;

          return inclusiveInterval
              ? comparedValue.isAfterOrSame(startValue, includeTime: includeTime) &&
                  comparedValue.isBeforeOrSame(endValue, includeTime: includeTime)
              : comparedValue.isAfter(startValue) && value.isBefore(endValue);
        },
        devError: devError ??
            (value) => 'Value $value (inclusiveInterval: $inclusiveInterval) is not in between $start and $end.',
        key: key ?? GladeErrorKeys.dateTimeIsBetweenError,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Compares given value with [start] value if it is after.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// With [includeTime] set to true(default), the comparison includes time.
  ///
  /// Default [key] is [ GladeErrorKeys.dateTimeIsAfterError].
  void isAfter({
    required DateTime start,
    OnValidate<DateTime>? devError,
    Object? key,
    ShouldValidateCallback<DateTime>? shouldValidate,
    bool inclusiveInterval = true,
    bool includeTime = true,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          final comparedValue = includeTime ? value : value.withoutTime;
          final startValue = includeTime ? start : start.withoutTime;

          return inclusiveInterval
              ? comparedValue.isAfterOrSame(startValue, includeTime: includeTime)
              : comparedValue.isAfter(startValue);
        },
        devError: devError ?? (value) => 'Value $value (inclusiveInterval: $inclusiveInterval) is not after $start',
        key: key ?? GladeErrorKeys.dateTimeIsAfterError,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Compares given value with [end] value if it is before.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// With [includeTime] set to true(default), the comparison includes time.
  ///
  /// Default [key] is [ GladeErrorKeys.dateTimeIsBeforeError].
  void isBefore({
    required DateTime end,
    OnValidate<DateTime>? devError,
    Object? key,
    ShouldValidateCallback<DateTime>? shouldValidate,
    bool inclusiveInterval = true,
    bool includeTime = true,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          final comparedValue = includeTime ? value : value.withoutTime;
          final endValue = includeTime ? end : end.withoutTime;

          return inclusiveInterval
              ? comparedValue.isBeforeOrSame(endValue, includeTime: includeTime)
              : comparedValue.isBefore(endValue);
        },
        devError: devError ?? (value) => 'Value $value (inclusiveInterval: $inclusiveInterval) is not before $end',
        key: key ?? GladeErrorKeys.dateTimeIsBeforeError,
        shouldValidate: shouldValidate,
        severity: severity,
      );
}

class DateTimeValidatorNullable extends GladeValidator<DateTime?> {
  /// Compares given value with [start] and [end] values.
  ///
  ///  With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// With [includeTime] set to true(default), the comparison includes time.
  ///
  /// Default [key] is [ GladeErrorKeys.dateTimeIsBetweenError].
  void isBetween({
    required DateTime start,
    required DateTime end,
    OnValidate<DateTime?>? devError,
    Object? key,
    ShouldValidateCallback<DateTime?>? shouldValidate,
    bool inclusiveInterval = true,
    bool includeTime = true,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          if (value == null) return false;

          final comparedValue = includeTime ? value : value.withoutTime;
          final startValue = includeTime ? start : start.withoutTime;
          final endValue = includeTime ? end : end.withoutTime;

          return inclusiveInterval
              ? comparedValue.isAfterOrSame(startValue, includeTime: includeTime) &&
                  comparedValue.isBeforeOrSame(endValue, includeTime: includeTime)
              : comparedValue.isAfter(startValue) && value.isBefore(endValue);
        },
        devError: devError ??
            (value) =>
                'Value ${value ?? 'NULL'} (inclusiveInterval: $inclusiveInterval) is not in between $start and $end.',
        key: key ?? GladeErrorKeys.dateTimeIsBetweenError,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Compares given value with [start] value if it is after.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// With [includeTime] set to true(default), the comparison includes time.
  ///
  /// Default [key] is [ GladeErrorKeys.dateTimeIsAfterError].
  void isAfter({
    required DateTime start,
    OnValidate<DateTime?>? devError,
    Object? key,
    ShouldValidateCallback<DateTime?>? shouldValidate,
    bool inclusiveInterval = true,
    bool includeTime = true,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          if (value == null) return false;

          final comparedValue = includeTime ? value : value.withoutTime;
          final startValue = includeTime ? start : start.withoutTime;

          return inclusiveInterval
              ? comparedValue.isAfterOrSame(startValue, includeTime: includeTime)
              : comparedValue.isAfter(startValue);
        },
        devError: devError ??
            (value) => 'Value ${value ?? 'NULL'} (inclusiveInterval: $inclusiveInterval) is not after $start',
        key: key ?? GladeErrorKeys.dateTimeIsAfterError,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Compares given value with [end] value if it is before.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// With [includeTime] set to true(default), the comparison includes time.
  void isBefore({
    required DateTime end,
    OnValidate<DateTime?>? devError,
    Object? key,
    ShouldValidateCallback<DateTime?>? shouldValidate,
    bool inclusiveInterval = true,
    bool includeTime = true,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          if (value == null) return false;

          final comparedValue = includeTime ? value : value.withoutTime;
          final endValue = includeTime ? end : end.withoutTime;

          return inclusiveInterval
              ? comparedValue.isBeforeOrSame(endValue, includeTime: includeTime)
              : comparedValue.isBefore(endValue);
        },
        devError: devError ??
            (value) => 'Value ${value ?? 'NULL'} (inclusiveInterval: $inclusiveInterval) is not before $end',
        key: key ?? GladeErrorKeys.dateTimeIsBeforeError,
        shouldValidate: shouldValidate,
        severity: severity,
      );
}
