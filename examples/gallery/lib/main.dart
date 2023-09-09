// ignore_for_file: prefer-match-file-name

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

// ignore: prefer-static-class, ok for now
final GlobalKey<NavigatorState> storyNavigatorKey = GlobalKey(debugLabel: 'storyNavigatorKey');

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWebOrDesktop = !Platform.isAndroid && !Platform.isIOS;

    return Storybook(
      plugins: isWebOrDesktop
          ? [
              const KnobsPlugin(),
              const ContentsPlugin(),
              DeviceFramePlugin(),
            ]
          : null,
      wrapperBuilder: (context, child) => MaterialApp(
        navigatorKey: storyNavigatorKey,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: child)),
      ),
      stories: const [
        // Story(
        //   name: 'Forms/TextInputvalidator',
        //   description: 'Usage of GenericValidator',
        //   builder: (context) => const WidgetExample(child: ValidatorInputsExample()),
        // ),
      ],
    );
  }

  // List<Story> _pickerStories() {
  //   return [
  //     Story(
  //       name: 'Pickers/ListPicker',
  //       description: 'Modal list picker. Allows to choose one value from predefined set of options.',
  //       builder: (context) => WidgetExample(
  //         supportsWebOrDesktop: false,
  //         child: ListPickerExample(
  //           noValueText: context.knobs.text(label: 'No value text', initial: 'Select value'),
  //           confirmButtonText: context.knobs.text(label: 'Confirm button text', initial: 'Ok'),
  //           backgroundColor: context.knobs.options<Color>(label: 'Background color', initial: Colors.white, options: [
  //             const Option(label: 'White', value: Colors.white),
  //             const Option(label: 'GreenBlue', value: Color(0xFF37C999)),
  //             const Option(label: 'Salmon', value: Color(0xFFE96E63)),
  //           ]),
  //         ),
  //       ),
  //     ),
  //   ];
  // }
}
