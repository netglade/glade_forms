import 'package:glade_forms/src/core/glade_error_keys.dart';
import 'package:glade_forms/src/validator/generic_validator.dart';
import 'package:glade_forms/src/validator/regex_patterns.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

class StringValidator extends GenericValidator<String?> {
  /// Checks that value is valid email address.
  ///
  /// Used Regex expression `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
  void isEmail({
    OnValidateError<String>? devError,
    Object? extra,
    bool allowEmpty = false,
    Object? key,
  }) =>
      satisfy(
        (x, _, __) {
          if (x?.isEmpty ?? true) {
            return allowEmpty;
          }

          final regExp = RegExp(RegexPatterns.email);

          return regExp.hasMatch(x!);
        },
        devError: devError ?? (value, _) => 'Value "${value ?? 'NULL'}" is not in e-mail format',
        extra: extra,
        key: key ?? GladeErrorKeys.stringNotEmail,
      );

  /// Checks that value is valid URL address.
  ///
  /// [requireHttpScheme] - if true HTTP(S) is mandatory.
  void isUrl({
    bool requireHttpScheme = false,
    OnValidateError<String>? devError,
    Object? extra,
    bool allowEmpty = false,
    Object? key,
  }) =>
      satisfy(
        (x, _, __) {
          if (x?.isEmpty ?? true) {
            return allowEmpty;
          }

          final regExp = RegExp(requireHttpScheme ? RegexPatterns.urlWithHttp : RegexPatterns.urlWithOptionalHttp);

          return regExp.hasMatch(x!);
        },
        devError: devError ?? (value, _) => 'Value "${value ?? 'NULL'}" is not valid URL address',
        extra: extra,
        key: key ?? GladeErrorKeys.stringNotUrl,
      );

  /// Given value can't be empty string (or null).
  void notEmpty({OnValidateError<String>? devError, Object? extra, Object? key}) => satisfy(
        (input, extra, __) => input?.isNotEmpty ?? false,
        devError: devError ?? (_, __) => "Value can't be empty",
        extra: extra,
        key: key ?? GladeErrorKeys.stringEmpty,
      );
}
