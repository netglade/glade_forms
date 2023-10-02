// ignore_for_file: prefer-match-file-name

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glade_forms_example/generated/locale_loader.g.dart';
import 'package:glade_forms_example/localization_addon_custom.dart';
import 'package:glade_forms_example/usecases/age_restricted_example.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
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

class EasyLocalePlugin extends Plugin {
  EasyLocalePlugin()
      : super(
          icon: (context) => const Icon(Icons.language),
          panelBuilder: (context) => ListView(
            children: context.supportedLocales.map((e) {
              final isCurrent = e == context.locale;

              return ListTile(
                title: Text(
                  e.languageCode,
                  style:
                      Theme.of(context).textTheme.labelMedium?.copyWith(color: isCurrent ? Colors.blue : Colors.black),
                ),
                onTap: () => context.setLocale(e),
              );
            }).toList(),
          ),
        );
}

class App extends HookWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = WidgetbookTheme(name: 'Light', data: ThemeData.light());

    return Widgetbook.material(
      // appBuilder: (context, child) => MaterialApp(
      //   locale: context.locale,
      //   localizationsDelegates: context.localizationDelegates,
      //   theme: ThemeData.light(),
      //   home: Material(child: child),
      // ),
      addons: [
        DeviceFrameAddon(
          devices: [Devices.ios.iPhone13],
          //  initialDevice: Devices.ios.iPhone13,
        ),
        MaterialThemeAddon(
          themes: [
            lightTheme,
            // WidgetbookTheme(name: 'Dark', data: ThemeData.dark()),
          ],
          initialTheme: lightTheme,
          //  themeBuilder: (context, theme, child) => Theme(data: theme, child: child),
        ),
        AlignmentAddon(),
        LocalizationAddonCustom(
          locales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          initialLocale: context.locale,
          onChange: (locale) => locale == null ? {} : context.setLocale(locale),
        ),
      ],
      directories: [
        WidgetbookUseCase(name: 'test', builder: (context) => const AgeRestrictedExample()),
      ],
    );
    // final themeMode = useState(ThemeMode.system);

    // return MaterialApp(
    //   theme: ThemeData.light(),
    //   darkTheme: ThemeData.dark(),
    //   themeMode: themeMode.value,
    //   debugShowCheckedModeBanner: false,
    //   localizationsDelegates: context.localizationDelegates,
    //   supportedLocales: context.supportedLocales,
    //   locale: context.locale,
    //   home: Storybook(
    //     initialStory: 'AgeRestrictedExample',
    //     plugins: [
    //       ThemeModePlugin(initialTheme: themeMode.value, onThemeChanged: (v) => themeMode.value = v),
    //       EasyLocalePlugin(),
    //     ],
    //     wrapperBuilder: (context, story) => Scaffold(body: story),
    //     stories: [
    //       Story(
    //         name: 'AgeRestrictedExample',
    //         description: 'Simple one field dependency',
    //         builder: (context) => AgeRestrictedExample(
    //           key: ValueKey(context.locale),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
