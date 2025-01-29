// ignore_for_file: prefer-match-file-name

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/generated/locale_keys.g.dart';

abstract final class _ErrorKeys {
  static const String ageRestriction = 'age-restriction';
}

class AgeRestrictedModel extends GladeModel {
  late GladeStringInput nameInput;
  late GladeStringInput fooInput;
  late GladeIntInput ageInput;
  late GladeBoolInput vipInput;

  @override
  List<GladeInput<Object?>> get inputs => [nameInput, fooInput, ageInput, vipInput];

  @override
  void initialize() {
    nameInput = GladeStringInput(
      inputKey: 'name-input',
      defaultTranslations: DefaultTranslations(
        defaultValueIsNullOrEmptyMessage: LocaleKeys.empty.tr(),
      ),
    );
    fooInput = GladeStringInput(
      inputKey: 'foo-input',
      defaultTranslations: DefaultTranslations(
        defaultValueIsNullOrEmptyMessage: LocaleKeys.empty.tr(),
      ),
      trackUnchanged: false,
    );
    ageInput = GladeIntInput(
      validator: (v) => (v
            ..notNull()
            ..isMin(min: 18, shouldValidate: (_) => vipInput.value))
          .build(),
      value: 0,
      dependencies: () => [vipInput],
      stringToValueConverter: GladeTypeConverters.intConverter,
      inputKey: 'age-input',
      translateError: (error, key, devMessage, dependencies) {
        if (key == _ErrorKeys.ageRestriction) return LocaleKeys.ageRestriction_under18.tr();

        if (error.isConversionError) return LocaleKeys.ageRestriction_ageFormat.tr();

        return devMessage;
      },
      onChange: (info) {
        vipInput.value = info.value >= 18;
      },
    );
    vipInput = GladeBoolInput(
      validator: (v) => (v..notNull()).build(),
      value: false,
      inputKey: 'vip-input',
      dependencies: () => [ageInput],
      onChange: (info) {
        if (info.value && ageInput.value < 18) {
          groupEdit(() {
            ageInput.value = 18;
          });
        }
      },
    );

    super.initialize();
  }
}

class DebugModelExample extends HookWidget {
  const DebugModelExample({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();

    return Scaffold(
      body: Center(
        child: TextField(
          controller: textController,
          onChanged: (v) => textController.text = v,
        ),
      ),
    );
  }
}
