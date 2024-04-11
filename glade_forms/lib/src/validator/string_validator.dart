import 'package:glade_forms/src/core/glade_error_keys.dart';
import 'package:glade_forms/src/validator/glade_validator.dart';
import 'package:glade_forms/src/validator/regex_patterns.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

class StringValidator extends GladeValidator<String> {
  StringValidator();

  /// Given value can't be empty string (or null).
  void notEmpty({OnValidateError<String>? devError, Object? key}) => satisfy(
        (input) => input.isNotEmpty,
        devError: devError ?? (_) => "Value can't be empty",
        key: key ?? GladeErrorKeys.stringEmpty,
      );

  /// Checks that value is valid email address.
  ///
  /// Used Regex expression `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
  void isEmail({
    OnValidateError<String>? devError,
    bool allowEmpty = false,
    Object? key,
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
      );

  /// Checks that value is valid URL address.
  ///
  /// [requiresScheme] - if true HTTP(S) is mandatory.
  /// Default [key] is [ GladeErrorKeys.stringNotUrl].
  void isUri({
    OnValidateError<String>? devError,
    bool allowEmpty = false,
    bool requiresScheme = false,
    Object key = GladeErrorKeys.stringNotUrl,
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
  }) =>
      satisfy(
        (value) {
          final regex =
              RegExp(pattern, multiLine: multiline, caseSensitive: caseSensitive, dotAll: dotAll, unicode: unicode);

          return regex.hasMatch(value);
        },
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" does not match regex',
        key: key ?? GladeErrorKeys.stringPatternMatch,
      );

  /// String's length has to be greater or equal to provided [length].
  void minLength({
    required int length,
    OnValidateError<String>? devError,
    Object? key,
  }) =>
      satisfy(
        (value) {
          return value.length >= length;
        },
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" is shorter than allowed length $length',
        key: key ?? GladeErrorKeys.stringMinLength,
      );

  /// String's length has to be less or equal to provided [length].
  void maxLength({
    required int length,
    OnValidateError<String>? devError,
    Object? key,
  }) =>
      satisfy(
        (value) => value.length < length,
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" is longer than allowed length $length',
        key: key ?? GladeErrorKeys.stringMaxLength,
      );

  /// String's length has to be equal to provided [length].
  void exactLength({
    required int length,
    OnValidateError<String>? devError,
    Object? key,
  }) =>
      satisfy(
        (value) => value.length == length,
        devError: devError ?? (value) => 'Value "${value ?? 'NULL'}" has to be $length long characters.',
        key: key ?? GladeErrorKeys.stringExactLength,
      );
}
