// ignore_for_file: prefer-match-file-name

import 'package:glade_forms/src/core/error/glade_input_error.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';

typedef ErrorTranslator<T> =
    String Function(
      /// Error to translate.
      GladeInputError<T> error,

      /// An error identification.
      Object? key,

      /// Default dev message.
      String devMessage,

      /// Input's dependencies.
      InputDependencies dependencies,
    );

class DefaultTranslations {
  /// Used when one of values `GladeErrorKeys.valueIsEmpty`,`GladeErrorKeys.valueIsNull`, `GladeErrorKeys.stringEmpty` is present.
  final String? defaultValueIsNullOrEmptyMessage;
  final String? defaultConversionMessage;

  const DefaultTranslations({
    this.defaultValueIsNullOrEmptyMessage,
    this.defaultConversionMessage,
  });
}
