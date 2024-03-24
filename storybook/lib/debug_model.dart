// ignore_for_file: prefer-match-file-name

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/generated/locale_keys.g.dart';

class _ErrorKeys {
  static const String ageRestriction = 'age-restriction';
}

class AgeRestrictedModel extends GladeModel {
  late StringInput nameInput;
  late StringInput fooInput;
  late GladeInput<int> ageInput;
  late GladeInput<bool> vipInput;

  @override
  List<GladeInput<Object?>> get inputs => [nameInput, fooInput, ageInput, vipInput];

  @override
  void initialize() {
    nameInput = GladeInput.stringInput(
      inputKey: 'name-input',
      defaultTranslations: DefaultTranslations(
        defaultValueIsNullOrEmptyMessage: LocaleKeys.empty.tr(),
      ),
    );
    fooInput = GladeInput.stringInput(
      inputKey: 'foo-input',
      defaultTranslations: DefaultTranslations(
        defaultValueIsNullOrEmptyMessage: LocaleKeys.empty.tr(),
      ),
      trackUnchanged: false,
    );
    ageInput = GladeInput.create(
      validator: (v) => (v
            ..notNull()
            ..satisfy(
              (value, extra, dependencies) {
                final vipContentInput = dependencies.byKey<bool>('vip-input');

                if (!vipContentInput.value) {
                  return true;
                }

                return value >= 18;
              },
              devError: (_, __) => 'When VIP enabled you must be at least 18 years old.',
              key: _ErrorKeys.ageRestriction,
            ))
          .build(),
      value: 0,
      dependencies: () => [vipInput],
      valueConverter: GladeTypeConverters.intConverter,
      inputKey: 'age-input',
      translateError: (error, key, devMessage, dependencies) {
        if (key == _ErrorKeys.ageRestriction) return LocaleKeys.ageRestriction_under18.tr();

        if (error.isConversionError) return LocaleKeys.ageRestriction_ageFormat.tr();

        return devMessage;
      },
      onChange: (info, dependencies) {
        dependencies.byKey<bool>('vip-input').value = info.value >= 18;
      },
    );
    vipInput = GladeInput.create(
      validator: (v) => (v..notNull()).build(),
      value: false,
      inputKey: 'vip-input',
      dependencies: () => [ageInput],
      onChange: (info, dependencies) {
        final age = dependencies.byKey<int>('age-input');

        if (info.value && age.value < 18) {
          groupEdit(() {
            age.value = 18;
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
