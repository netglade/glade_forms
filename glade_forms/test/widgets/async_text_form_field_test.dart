import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glade_forms/glade_forms.dart';

class _Model extends GladeModel {
  final Set<String> taken;

  late GladeStringInput username;

  int serverCalls = 0;

  final String _initial;

  @override
  List<GladeInput<Object?>> get inputs => [username];

  _Model({required this.taken, required String initial}) : _initial = initial;

  @override
  void initialize() {
    username = GladeStringInput(
      inputKey: 'username',
      initialValue: _initial,
      validator: (v) =>
          (v..satisfyAsync(
                (value) async {
                  serverCalls++;
                  // Simulates server latency.
                  await Future<void>.delayed(const Duration(milliseconds: 100));

                  return !taken.contains(value);
                },
                key: 'taken',
                devMessage: (_) => 'Username is taken',
              ))
              .build(asyncDebounce: const Duration(milliseconds: 300)),
    );

    super.initialize();
  }
}

class _App extends StatelessWidget {
  final _Model model;
  final AutovalidateMode mode;

  const _App({required this.model, required this.mode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GladeFormBuilder<_Model>.value(
          value: model,
          builder: (context, formModel, _) => Form(
            autovalidateMode: mode,
            child: TextFormField(
              controller: formModel.username.controller,
              validator: formModel.username.textFormFieldInputValidator,
              decoration: InputDecoration(
                suffixIcon: formModel.username.isValidating
                    ? const Icon(Icons.hourglass_top, key: Key('spinner'))
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  setUp(GladeForms.initialize);

  testWidgets('onUserInteraction: async error appears after response without further interaction', (tester) async {
    // arrange
    final model = _Model(taken: {'taken'}, initial: '');
    await tester.pumpWidget(_App(model: model, mode: .onUserInteraction));

    // act
    await tester.enterText(find.byType(TextFormField), 'taken');
    await tester.pump();

    // assert: pending, no message, spinner shown
    expect(find.text('Username is taken'), findsNothing);
    expect(find.byKey(const Key('spinner')), findsOneWidget);
    expect(model.isValid, isFalse);

    await tester.pump(const Duration(milliseconds: 300)); // debounce
    await tester.pump(const Duration(milliseconds: 100)); // server
    await tester.pump(); // rebuild after notifyListeners

    expect(find.text('Username is taken'), findsOneWidget);
    expect(find.byKey(const Key('spinner')), findsNothing);
    expect(model.serverCalls, equals(1));

    model.dispose();
  });

  testWidgets('always: initial value is validated asynchronously on first build', (tester) async {
    // arrange
    final model = _Model(taken: {'taken'}, initial: 'taken');

    // act
    await tester.pumpWidget(_App(model: model, mode: .always));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // assert
    expect(model.serverCalls, equals(1));
    expect(find.text('Username is taken'), findsOneWidget);

    model.dispose();
  });

  testWidgets('onUserInteraction: initial value is not validated until interaction', (tester) async {
    // arrange
    final model = _Model(taken: {'taken'}, initial: 'taken');

    // act
    await tester.pumpWidget(_App(model: model, mode: .onUserInteraction));
    await tester.pump(const Duration(seconds: 1));

    // assert
    expect(model.serverCalls, isZero);
    expect(model.isValid, isTrue);

    model.dispose();
  });
}
