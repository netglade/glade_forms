import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/core/glade_error_keys.dart';

abstract final class GladeTypeConverters {
  static final intConverter = StringToTypeConverter<int>(
    converter: (rawValue, cantConvert) {
      if (rawValue == null) {
        return cantConvert('Input can not be null', rawValue: rawValue, key: GladeErrorKeys.valueIsNull);
      }

      return int.tryParse(rawValue) ?? cantConvert('Can not convert', rawValue: rawValue);
    },
    converterBack: (rawInput) => rawInput.toString(),
  );

  static final boolConverter = StringToTypeConverter<bool>(
    converter: (rawValue, cantConvert) {
      if (rawValue == null) {
        return cantConvert('Input can not be null', rawValue: rawValue, key: GladeErrorKeys.valueIsNull);
      }

      return bool.tryParse(rawValue) ?? cantConvert('Can not convert', rawValue: rawValue);
    },
    converterBack: (rawInput) => rawInput.toString(),
  );

  static final dateTimeIso8601 = StringToTypeConverter<DateTime>(
    converter: (rawValue, cantConvert) {
      if (rawValue == null) {
        return cantConvert('Input can not be null', rawValue: rawValue, key: GladeErrorKeys.valueIsNull);
      }

      return DateTime.tryParse(rawValue) ?? cantConvert('Can not convert', rawValue: rawValue);
    },
    converterBack: (rawInput) => rawInput.toIso8601String(),
  );
}
