// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader {
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String, dynamic> cs_CZ = {
    "ageRestriction": {"under18": "Musí vám být alespoň 18 let pro vstup", "ageFormat": "Věk musí být číslo"},
    "empty": "Povinná hodnota",
  };
  static const Map<String, dynamic> en_US = {
    "ageRestriction": {"under18": "You must be at least 18 years old for entry", "ageFormat": "Age has to be number"},
    "empty": "You must fill in value",
  };
  static const Map<String, Map<String, dynamic>> mapLocales = {"cs_CZ": cs_CZ, "en_US": en_US};
}
