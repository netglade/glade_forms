// ignore_for_file: prefer-match-file-name

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:glade_forms_example/generated/locale_loader.g.dart';
import 'package:glade_forms_example/localization_addon_custom.dart';
import 'package:glade_forms_example/usecases/age_restricted_example.dart';
import 'package:glade_forms_example/usecases/complex_object_mapping_example.dart';
import 'package:widgetbook/widgetbook.dart';

// ignore: prefer-static-class, ok for now
final GlobalKey<NavigatorState> storyNavigatorKey = GlobalKey(debugLabel: 'storyNavigatorKey');

void main() async {
  final _ = WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('cs', 'CZ')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      assetLoader: const CodegenLoader(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        LocalizationAddonCustom(
          locales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          initialLocale: context.locale,
          onChange: (locale) => locale == null ? {} : context.setLocale(locale),
        ),
      ],
      directories: [
        WidgetbookCategory(
          name: 'Dependencies',
          children: [
            WidgetbookUseCase(name: 'One checkbox dependency', builder: (context) => const AgeRestrictedExample()),
          ],
        ),
        WidgetbookCategory(
          name: 'Complex types',
          children: [
            WidgetbookUseCase(
              name: 'Complex objects & converters',
              builder: (context) => const ComplexMappingExample(),
            ),
          ],
        ),
      ],
    );
  }
}
