import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_example/generated/locale_keys.g.dart';
import 'package:glade_forms_example/shared/model_debug_info.dart';
import 'package:glade_forms_example/shared/usecase_container.dart';

class _ErrorKeys {
  static const String ageRestriction = 'age-restriction';
}

class _Model extends MutableGenericModel {
  late StringInput nameInput;
  late GladeInput<int> ageInput;
  late GladeInput<bool> vipInput;

  @override
  List<GladeInput<Object?>> get inputs => [nameInput, ageInput, vipInput];

  _Model() {
    nameInput = StringInput.required(
      inputKey: 'name-input',
      defaultTranslations: DefaultTranslations(
        defaultValueIsNullOrEmptyMessage: LocaleKeys.empty.tr(),
      ),
    );
    ageInput = GladeInput.create(
      (v) => (v
            ..notNull()
            ..satisfy(
              (value, extra, dependencies) {
                final vipContentInput = dependencies.byKey<bool>('vip-input');

                if (vipContentInput == null || !vipContentInput.value) {
                  return true;
                }

                return value >= 18;
              },
              devError: (_, __) => 'When VIP enabled you must be at least 18 years old.',
              key: _ErrorKeys.ageRestriction,
            ))
          .build(),
      value: 0,
      valueConverter: StringToTypeConverter(
        converter: (rawInput, cantConvert) {
          if (rawInput == null) return cantConvert(error: 'Input can not be null', rawValue: rawInput);

          return int.tryParse(rawInput) ?? cantConvert(error: 'Can not convert', rawValue: rawInput);
        },
      ),
      inputKey: 'age-input',
      translateError: (error, key, devMessage, {required dependencies}) {
        if (key == _ErrorKeys.ageRestriction) return LocaleKeys.ageRestriction_under18.tr();

        if (error.isConversionError) return LocaleKeys.ageRestriction_ageFormat.tr();

        return devMessage;
      },
      dependencies: () => [vipInput],
    );
    vipInput = GladeInput.create(
      (v) => (v..notNull()).build(),
      value: false,
      inputKey: 'vip-input',
    );
  }
}

class AgeRestrictedExample extends StatelessWidget {
  const AgeRestrictedExample({super.key});

  @override
  Widget build(BuildContext context) {
    const markdownData = '''
If *VIP content* is checked, **age** must be over 18.
 ''';

    return UsecaseContainer(
      shortDescription: 'If *VIP content* is checked, **age** must be over 18.',
      description: markdownData,
      child: GladeFormBuilder(
        create: (context) => _Model(),
        builder: (context, formModel) => Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: formModel.nameInput.value,
                  onChanged: (value) => formModel.stringFieldUpdateInput(formModel.nameInput, value),
                  validator: formModel.nameInput.formFieldInputValidator,
                ),
                TextFormField(
                  initialValue: formModel.ageInput.stringValue,
                  onChanged: (value) => formModel.stringFieldUpdateInput(formModel.ageInput, value),
                  validator: (v) => formModel.ageInput.formFieldInputValidator(v),
                ),
                CheckboxListTile(
                  value: formModel.vipInput.value,
                  title: const Text('VIP Content'),
                  onChanged: (value) => formModel.updateInput(formModel.vipInput, value),
                ),
                ElevatedButton(
                  onPressed: formModel.isValid
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                        }
                      : null,
                  child: const Text('Save'),
                ),
                ModelDebugInfo(model: formModel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
