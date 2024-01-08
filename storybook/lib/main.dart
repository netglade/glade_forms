// ignore_for_file: prefer-match-file-name

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:glade_forms_storybook/generated/locale_loader.g.dart';
import 'package:glade_forms_storybook/localization_addon_custom.dart';
import 'package:glade_forms_storybook/usecases/complex_object_mapping_example.dart';
import 'package:glade_forms_storybook/usecases/one_checkbox_deps_validation.dart';
import 'package:glade_forms_storybook/usecases/quickstart_async_example.dart';
import 'package:glade_forms_storybook/usecases/quickstart_example.dart';
import 'package:glade_forms_storybook/usecases/two_way_checkbox_change.dart';
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
          // ignore: avoid-async-call-in-sync-function, ok here.
          onChange: (locale) => context.setLocale(locale),
        ),
      ],
      directories: [
        WidgetbookUseCase(name: 'Quickstart form', builder: (context) => const QuickStartExample()),
        WidgetbookUseCase(name: 'Quickstart async form', builder: (context) => const QuickStartAsyncExample()),
        WidgetbookCategory(
          name: 'Dependencies',
          children: [
            WidgetbookUseCase(
              name: 'One checkbox dependency',
              builder: (context) => const OneCheckboxValidationDependencyExample(),
            ),
            WidgetbookUseCase(
              name: 'Two-way checkbox dependency',
              builder: (context) => const TwoWayCheckboxExample(),
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Complex types',
          children: [
            WidgetbookUseCase(
              name: 'Complex objects & converters',
              builder: (context) => const ComplexObjectMappingExample(),
            ),
          ],
        ),
      ],
    );
  }
}
