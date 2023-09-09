import 'package:glade_forms/src/validator/generic_validator.dart';
import 'package:glade_forms/src/validator/regex_patterns.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

class StringValidator extends GenericValidator<String> {
  /// Checks that value is valid email address.
  ///
  /// Used Regex expression `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
  void isEmail({
    OnError<String>? devError,
    Object? extra,
    bool allowEmpty = false,
    Object? localeKey,
  }) =>
      satisfy(
        (x, _) {
          if (x == null || x.isEmpty) {
            return allowEmpty;
          }

          final regExp = RegExp(RegexPatterns.email);

          return regExp.hasMatch(x);
        },
        devError: devError ?? (value, _) => 'Value "$value" is not in e-mail format',
        extra: extra,
        localeKey: localeKey,
      );

  /// Checks that value is valid URL address.
  ///
  /// [requireHttpScheme] - if true HTTP(S) is mandatory.
  void isUrl({
    bool requireHttpScheme = false,
    OnError<String>? devError,
    Object? extra,
    bool allowEmpty = false,
    Object? localeKey,
  }) =>
      satisfy(
        (x, _) {
          if (x == null || x.isEmpty) {
            return allowEmpty;
          }

          final regExp = RegExp(requireHttpScheme ? RegexPatterns.urlWithHttp : RegexPatterns.urlWithOptionalHttp);

          return regExp.hasMatch(x);
        },
        devError: devError ?? (value, _) => 'Value "$value" is not valid URL address',
        extra: extra,
        localeKey: localeKey,
      );

  /// Given value can't be empty string (or null).
  void notEmpty({
    OnError<String>? devError,
    Object? extra,
    Object? localeKey,
  }) =>
      satisfy(
        (input, extra) => input?.isNotEmpty ?? false,
        devError: devError ?? (_, __) => "Value can't be empty",
        extra: extra,
        localeKey: localeKey,
      );
}
