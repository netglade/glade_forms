import 'package:glade_forms/src/core/glade_error_keys.dart';
import 'package:glade_forms/src/validator/validator.dart';

class StringValidator extends GladeValidator<String> {
  StringValidator();

  /// Given value can't be empty string (or null).
  void notEmpty({
    OnValidateError<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
    bool allowBlank = true,
  }) =>
      satisfy(
        (input) => allowBlank ? input.isNotEmpty : input.trim().isNotEmpty,
        devError: devError ?? (_) => "Value can't be empty",
        key: key ?? GladeErrorKeys.stringEmpty,
        shouldValidate: shouldValidate,
      );

  /// Checks that value is valid email address.
  ///
  /// Used Regex expression `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
  void isEmail({
    OnValidateError<String>? devError,
    bool allowEmpty = false,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (x) {
          if (x.isEmpty) {
            return allowEmpty;
          }

          final regExp = RegExp(RegexPatterns.email);

          return regExp.hasMatch(x);
        },
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" is not in e-mail format',
        key: key ?? GladeErrorKeys.stringNotEmail,
        shouldValidate: shouldValidate,
      );

  /// Checks that value is valid URL address.
  ///
  /// [requiresScheme] - if true HTTP(S) is mandatory.
  /// Default [key] is [ GladeErrorKeys.stringNotUrl].
  void isUrl({
    OnValidateError<String>? devError,
    bool allowEmpty = false,
    bool requiresScheme = false,
    Object key = GladeErrorKeys.stringNotUrl,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (value) {
          if (value.isEmpty) {
            return allowEmpty;
          }

          final quantifier = requiresScheme ? '{1}' : '?';

          final exp = RegExp(
            // ignore: unnecessary_string_escapes, regex pattern.
            r'^(?:https?:\/\/)' +
                quantifier +
                r'(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$',
          );

          return exp.hasMatch(value);
        },
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" is not valid URL address',
        key: key,
        shouldValidate: shouldValidate,
      );

  /// Matches provided regex [pattern].
  void match({
    required String pattern,
    bool multiline = false,
    bool caseSensitive = true,
    bool dotAll = false,
    bool unicode = false,
    OnValidateError<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (value) {
          final regex =
              RegExp(pattern, multiLine: multiline, caseSensitive: caseSensitive, dotAll: dotAll, unicode: unicode);

          return regex.hasMatch(value);
        },
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" does not match regex',
        key: key ?? GladeErrorKeys.stringPatternMatch,
        shouldValidate: shouldValidate,
      );

  /// String's length has to be greater or equal to provided [length].
  void minLength({
    required int length,
    OnValidateError<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (value) {
          return value.length >= length;
        },
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" is shorter than allowed length $length',
        key: key ?? GladeErrorKeys.stringMinLength,
        shouldValidate: shouldValidate,
      );

  /// String's length has to be less or equal to provided [length].
  void maxLength({
    required int length,
    OnValidateError<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (value) => value.length < length,
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" is longer than allowed length $length',
        key: key ?? GladeErrorKeys.stringMaxLength,
        shouldValidate: shouldValidate,
      );

  /// String's length has to be equal to provided [length].
  void exactLength({
    required int length,
    OnValidateError<String>? devError,
    Object? key,
    ShouldValidateCallback<String>? shouldValidate,
  }) =>
      satisfy(
        (value) => value.length == length,
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" has to be $length long characters.',
        key: key ?? GladeErrorKeys.stringExactLength,
        shouldValidate: shouldValidate,
      );
}
