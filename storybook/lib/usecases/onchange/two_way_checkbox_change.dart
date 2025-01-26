// ignore_for_file: prefer-match-file-name, avoid-passing-self-as-argument, prefer-single-widget-per-file

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/generated/locale_keys.g.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

abstract final class _ErrorKeys {
  static const String ageRestriction = 'age-restriction';
}

class AgeRestrictedModel extends GladeModel {
  late GladeStringInput nameInput;
  late GladeIntInput ageInput;
  late GladeBoolInput vipInput;

  @override
  List<GladeInput<Object?>> get inputs => [nameInput, ageInput, vipInput];

  @override
  void initialize() {
    nameInput = GladeStringInput(
      inputKey: 'name-input',
      defaultTranslations: DefaultTranslations(
        defaultValueIsNullOrEmptyMessage: LocaleKeys.empty.tr(),
      ),
    );
    ageInput = GladeIntInput(
      validator: (v) => (v
            ..notNull()
            ..isMin(min: 18, shouldValidate: (_) => vipInput.value, key: _ErrorKeys.ageRestriction))
          .build(),
      value: 0,
      inputKey: 'age-input',
      translateError: (error, key, devMessage, dependencies) {
        if (key == _ErrorKeys.ageRestriction) return LocaleKeys.ageRestriction_under18.tr();

        if (error.isConversionError) return LocaleKeys.ageRestriction_ageFormat.tr();

        return devMessage;
      },
      useTextEditingController: true,
    );
    vipInput = GladeBoolInput(
      validator: (v) => (v..notNull()).build(),
      value: false,
      inputKey: 'vip-input',
      dependencies: () => [ageInput],
      onDependencyChange: (updateInputKeys) {
        if (updateInputKeys.contains('age-input')) {
          vipInput.updateValue(ageInput.value >= 18, shouldTriggerOnChange: false);
        }
      },
      onChange: (info) {
        if (info.value && ageInput.value < 18) {
          ageInput.updateValue(18, shouldTriggerOnChange: false);
        }
      },
    );

    super.initialize();
  }
}

class TwoWayCheckboxExample extends StatelessWidget {
  const TwoWayCheckboxExample({super.key});

  @override
  Widget build(BuildContext context) {
    const markdownData = '''
If *VIP content* is checked, **age** must be over 18 or it is changed to 18.

If *age* is changed to value under 18, *vip content* is unchecked and vice-versa.
 ''';

    return UsecaseContainer(
      shortDescription: "Age input depends on checkbox's value automatically",
      description: markdownData,
      className: 'onchange/two_way_checkbox_change.dart',
      child: GladeFormBuilder.create(
        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
        create: (context) => AgeRestrictedModel(),
        builder: (context, formModel, _) => Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: ListView(
              children: [
                TextFormField(
                  controller: formModel.nameInput.controller,
                  decoration: const InputDecoration(labelText: 'Name'),
                  // onChanged: formModel.nameInput.updateValueWithString,
                  validator: formModel.nameInput.textFormFieldInputValidator,
                ),
                TextFormField(
                  controller: formModel.ageInput.controller,
                  decoration: const InputDecoration(labelText: 'Age'),
                  //  onChanged: formModel.ageInput.updateValueWithString,
                  validator: (v) => formModel.ageInput.textFormFieldInputValidator(v),
                ),
                CheckboxListTile(
                  value: formModel.vipInput.value,
                  title: const Text('VIP Content'),
                  onChanged: (v) => formModel.vipInput.value = v ?? false,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: formModel.isValid
                        ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')))
                        : null,
                    child: const Text('Save'),
                  ),
                ),
                const GladeModelDebugInfo<AgeRestrictedModel>(
                  showControllerText: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
