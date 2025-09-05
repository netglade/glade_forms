import 'package:glade_forms/src/core/error/glade_validations_keys.dart';
import 'package:glade_forms/src/core/error/validation_severity.dart';
import 'package:glade_forms/src/validator/validator.dart';

typedef StringValidatorFactory = ValidatorInstance<String> Function(StringValidator validator);

class StringValidator extends GladeValidator<String> {
  /// Given value can't be empty string (or null).
  ///
  /// If [allowBlank] is set to true, the value can be empty string.
  ///
  /// Default [key] is [ GladeValidationsKeys.stringEmpty].
  void notEmpty({
    OnValidate<String>? devMessage,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    bool allowBlank = true,
    ValidationSeverity severity = ValidationSeverity.error,
  }) =>
      satisfy(
        (input) => allowBlank ? input.isNotEmpty : input.trim().isNotEmpty,
        devMessage: devMessage ?? (_) => "Value can't be empty",
        key: key ?? GladeValidationsKeys.stringEmpty,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Checks that value is valid email address.
  ///
  /// Used Regex expression `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
  ///
  /// If [allowEmpty] is set to true, the value can be empty string.
  ///
  /// Default [key] is [ GladeValidationsKeys.stringNotEmail].
  void isEmail({
    OnValidate<String>? devMessage,
    bool allowEmpty = false,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ValidationSeverity severity = ValidationSeverity.error,
  }) =>
      satisfy(
        (x) {
          if (x.isEmpty) {
            return allowEmpty;
          }

          final regExp = RegExp(RegexPatterns.email);

          return regExp.hasMatch(x);
        },
        devMessage: devMessage ?? (value) => 'Value "$value" is not in e-mail format',
        key: key ?? GladeValidationsKeys.stringNotEmail,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Checks that value is valid URL address.
  ///
  /// [requiresScheme] - if true HTTP(S) is mandatory.
  ///
  /// Default [key] is [ GladeValidationsKeys.stringNotUrl].
  void isUrl({
    OnValidate<String>? devMessage,
    bool allowEmpty = false,
    bool requiresScheme = false,
    Object key = GladeValidationsKeys.stringNotUrl,
    ShouldValidateCallback<String>? shouldValidate,
    ValidationSeverity severity = ValidationSeverity.error,
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
        devMessage: devMessage ?? (value) => 'Value "$value" is not valid URL address',
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
  /// Default [key] is [ GladeValidationsKeys.stringPatternMatch].
  void match({
    required String pattern,
    bool multiline = false,
    bool caseSensitive = true,
    bool dotAll = false,
    bool unicode = false,
    OnValidate<String>? devMessage,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ValidationSeverity severity = ValidationSeverity.error,
  }) =>
      satisfy(
        (value) {
          final regex =
              RegExp(pattern, multiLine: multiline, caseSensitive: caseSensitive, dotAll: dotAll, unicode: unicode);

          return regex.hasMatch(value);
        },
        devMessage: devMessage ?? (value) => 'Value "$value" does not match regex',
        key: key ?? GladeValidationsKeys.stringPatternMatch,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// String's length has to be greater or equal to provided [length].
  ///
  /// Default [key] is [ GladeValidationsKeys.stringMinLength].
  void minLength({
    required int length,
    OnValidate<String>? devMessage,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ValidationSeverity severity = ValidationSeverity.error,
  }) =>
      satisfy(
        (value) {
          return value.length >= length;
        },
        devMessage: devMessage ?? (value) => 'Value "$value" is shorter than allowed length $length',
        key: key ?? GladeValidationsKeys.stringMinLength,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// String's length has to be less or equal to provided [length].
  ///
  /// Default [key] is [ GladeValidationsKeys.stringMaxLength].
  void maxLength({
    required int length,
    OnValidate<String>? devMessage,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (value) => value.length < length,
        devMessage: devMessage ?? (value) => 'Value "$value " is longer than allowed length $length',
        key: key ?? GladeValidationsKeys.stringMaxLength,
        shouldValidate: shouldValidate,
        metaData: length,
      );

  /// String's length has to be equal to provided [length].
  ///
  /// Default [key] is [ GladeValidationsKeys.stringExactLength].
  void exactLength({
    required int length,
    OnValidate<String>? devMessage,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    ValidationSeverity severity = ValidationSeverity.error,
  }) =>
      satisfy(
        (value) => value.length == length,
        devMessage: devMessage ?? (value) => 'Value "$value " has to be $length long characters.',
        key: key ?? GladeValidationsKeys.stringExactLength,
        shouldValidate: shouldValidate,
        severity: severity,
      );
}
