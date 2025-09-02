import 'package:glade_forms/src/core/error/error_serverity.dart';
import 'package:glade_forms/src/core/error/glade_error_keys.dart';
import 'package:glade_forms/src/validator/validator.dart';

typedef StringValidatorFactory = ValidatorInstance<String> Function(StringValidator validator);

class StringValidator extends GladeValidator<String> {
  /// Given value can't be empty string (or null).
  ///
  /// If [allowBlank] is set to true, the value can be empty string.
  ///
  /// Default [key] is [ GladeErrorKeys.stringEmpty].
  void notEmpty({
    OnValidate<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    bool allowBlank = true,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (input) => allowBlank ? input.isNotEmpty : input.trim().isNotEmpty,
        devError: devError ?? (_) => "Value can't be empty",
        key: key ?? GladeErrorKeys.stringEmpty,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Checks that value is valid email address.
  ///
  /// Used Regex expression `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
  ///
  /// If [allowEmpty] is set to true, the value can be empty string.
  ///
  /// Default [key] is [ GladeErrorKeys.stringNotEmail].
  void isEmail({
    OnValidate<String>? devError,
    bool allowEmpty = false,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (x) {
          if (x.isEmpty) {
            return allowEmpty;
          }

          final regExp = RegExp(RegexPatterns.email);

          return regExp.hasMatch(x);
        },
        devError: devError ?? (value) => 'Value "$value" is not in e-mail format',
        key: key ?? GladeErrorKeys.stringNotEmail,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Checks that value is valid URL address.
  ///
  /// [requiresScheme] - if true HTTP(S) is mandatory.
  ///
  /// Default [key] is [ GladeErrorKeys.stringNotUrl].
  void isUrl({
    OnValidate<String>? devError,
    bool allowEmpty = false,
    bool requiresScheme = false,
    Object key = GladeErrorKeys.stringNotUrl,
    ShouldValidateCallback<String>? shouldValidate,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          if (value.isEmpty) {
            return allowEmpty;
          }

          final quantifier = requiresScheme ? '{1}' : '?';

          final exp = RegExp(
            r'^(?:https?:\/\/)' +
                quantifier +
                r'(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$',
          );

          return exp.hasMatch(value);
        },
        devError: devError ?? (value) => 'Value "$value" is not valid URL address',
        key: key,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Matches provided regex [pattern].
  ///
  /// [multiline] - if true, the pattern will match line terminators.
  ///
  /// [caseSensitive] - if false, the pattern will ignore case.
  ///
  /// [dotAll] - if true, the pattern will match any character including line terminators.
  ///
  /// [unicode] - if true, the pattern will match unicode characters.
  ///
  /// Default [key] is [ GladeErrorKeys.stringPatternMatch].
  void match({
    required String pattern,
    bool multiline = false,
    bool caseSensitive = true,
    bool dotAll = false,
    bool unicode = false,
    OnValidate<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          final regex =
              RegExp(pattern, multiLine: multiline, caseSensitive: caseSensitive, dotAll: dotAll, unicode: unicode);

          return regex.hasMatch(value);
        },
        devError: devError ?? (value) => 'Value "$value" does not match regex',
        key: key ?? GladeErrorKeys.stringPatternMatch,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// String's length has to be greater or equal to provided [length].
  ///
  /// Default [key] is [ GladeErrorKeys.stringMinLength].
  void minLength({
    required int length,
    OnValidate<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) {
          return value.length >= length;
        },
        devError: devError ?? (value) => 'Value "$value" is shorter than allowed length $length',
        key: key ?? GladeErrorKeys.stringMinLength,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// String's length has to be less or equal to provided [length].
  ///
  /// Default [key] is [ GladeErrorKeys.stringMaxLength].
  void maxLength({
    required int length,
    OnValidate<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (value) => value.length < length,
        devError: devError ?? (value) => 'Value "$value " is longer than allowed length $length',
        key: key ?? GladeErrorKeys.stringMaxLength,
        shouldValidate: shouldValidate,
        metaData: length,
      );

  /// String's length has to be equal to provided [length].
  ///
  /// Default [key] is [ GladeErrorKeys.stringExactLength].
  void exactLength({
    required int length,
    OnValidate<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      satisfy(
        (value) => value.length == length,
        devError: devError ?? (value) => 'Value "$value " has to be $length long characters.',
        key: key ?? GladeErrorKeys.stringExactLength,
        shouldValidate: shouldValidate,
        severity: severity,
      );
}
