// ignore_for_file: prefer-match-file-name

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:glade_forms_storybook/generated/locale_loader.g.dart';
import 'package:glade_forms_storybook/localization_addon_custom.dart';
import 'package:glade_forms_storybook/usecases/complex_object_mapping_example.dart';
import 'package:glade_forms_storybook/usecases/dependencies/checkbox_dependency_change.dart';
import 'package:glade_forms_storybook/usecases/onchange/one_checkbox_deps_validation.dart';
import 'package:glade_forms_storybook/usecases/onchange/two_way_checkbox_change.dart';
import 'package:glade_forms_storybook/usecases/quickstart_example.dart';
import 'package:glade_forms_storybook/usecases/regress/issue48_text_controller_example.dart';
import 'package:glade_forms_storybook/usecases/warning_input_example.dart';
import 'package:widgetbook/widgetbook.dart';

// ignore: prefer-static-class, ok for now
final GlobalKey<NavigatorState> storyNavigatorKey = GlobalKey(debugLabel: 'storyNavigatorKey');

void main() async {
  final _ = WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  const isDebugModel = String.fromEnvironment('DEBUG_MODEL', defaultValue: 'false') == 'true';

  if (isDebugModel) {
    runApp(const _DebugModelApp());
  }

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

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}

class _DebugModelApp extends StatelessWidget {
  const _DebugModelApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Issue48TextControllerExample());
  }
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
        WidgetbookUseCase(name: 'Warning input example', builder: (context) => const WarningInputExample()),
        WidgetbookCategory(
          name: 'onChange',
          children: [
            WidgetbookUseCase(
              name: 'One checkbox onChange',
              builder: (context) => const OneCheckboxValidationDependencyExample(),
            ),
            WidgetbookUseCase(
              name: 'Two-way checkbox onChange',
              builder: (context) => const TwoWayCheckboxExample(),
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Dependency',
          children: [
            WidgetbookUseCase(
              name: 'Checkbox dependency',
              builder: (context) => const CheckboxDependencyExample(),
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
        WidgetbookCategory(
          name: 'Issues',
          children: [
            WidgetbookUseCase(
              name: 'TextEditingController issue',
              builder: (context) => const Issue48TextControllerExample(),
            ),
          ],
        ),
      ],
    );
  }
}
