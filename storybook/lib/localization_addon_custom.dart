// ignore_for_file: prefer-match-file-name, avoid-non-null-assertion

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// A [WidgetbookAddon] for changing the active [Locale] via [Localizations].
class LocalizationAddonCustom extends WidgetbookAddon<Locale> {
  final List<Locale> locales;
  // ignore: avoid-dynamic, ok here
  final List<LocalizationsDelegate<dynamic>> localizationsDelegates;
  final ValueChanged<Locale> onChange;

  @override
  List<Field> get fields {
    return [
      ListField<Locale>(
        name: 'name',
        values: locales,
        // TODO(widgetbook): update deprecated
        // ignore: deprecated_member_use, ok for now
        initialValue: initialSetting,
        labelBuilder: (locale) => locale.toLanguageTag(),
        // TODO(widgetbook): update deprecated
        // ignore: deprecated_member_use, ok for now
        onChanged: (context, locale) => locale != null ? onChange(locale) : null,
      ),
    ];
  }

  LocalizationAddonCustom({
    required this.locales,
    required this.localizationsDelegates,
    required this.onChange,
    Locale? initialLocale,
  })  : assert(
          locales.isNotEmpty,
          'locales cannot be empty',
        ),
        assert(
          initialLocale == null || locales.contains(initialLocale),
          'initialLocale must be in locales',
        ),
        super(
          name: 'Locale',
          // TODO(widgetbook): update deprecated
          // ignore: deprecated_member_use, ok for now, avoid-unsafe-collection-methods, ok here
          initialSetting: initialLocale ?? locales.first,
        );

  @override
  Locale valueFromQueryGroup(Map<String, String> group) {
    return valueOf('name', group)!;
  }

  @override
  Widget buildUseCase(BuildContext context, Widget child, Locale setting) {
    return Localizations(
      locale: setting,
      delegates: localizationsDelegates,
      child: child,
    );
  }
}
