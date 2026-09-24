import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/usecases/composed/composed_with_own_inputs_example.dart';

void main() {
  setUp(GladeForms.initialize);

  testWidgets('Composed model own inputs are shown next to its member forms', (tester) async {
    // arrange
    const example = MaterialApp(home: ComposedWithOwnInputsExample());

    // act
    await tester.pumpWidget(example);
    await tester.pumpAndSettle();

    // assert
    expect(find.text('Team'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Team name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Motto (optional)'), findsOneWidget);
    expect(find.text('Member #1'), findsOneWidget);
    expect(find.text('Something is missing'), findsOneWidget);
  });

  testWidgets("Composed model's own input drives the form validity and reports its key", (tester) async {
    // arrange
    await tester.pumpWidget(const MaterialApp(home: ComposedWithOwnInputsExample()));
    await tester.pumpAndSettle();

    // act
    await tester.enterText(find.widgetWithText(TextFormField, 'Team name'), 'A-team');
    await tester.enterText(find.widgetWithText(TextFormField, 'First name'), 'John');
    await tester.enterText(find.widgetWithText(TextFormField, 'Last name'), 'Doe');
    await tester.pumpAndSettle();

    // assert
    expect(find.text('Everything is filled'), findsOneWidget);
    expect(find.text('Last updated: teamName'), findsNothing, reason: 'the last change was in the member form');
    expect(find.textContaining('Last updated:'), findsOneWidget);
  });

  testWidgets('An empty team name keeps the form invalid even when every member is filled', (tester) async {
    // arrange
    await tester.pumpWidget(const MaterialApp(home: ComposedWithOwnInputsExample()));
    await tester.pumpAndSettle();

    // act
    await tester.enterText(find.widgetWithText(TextFormField, 'First name'), 'John');
    await tester.enterText(find.widgetWithText(TextFormField, 'Last name'), 'Doe');
    await tester.pumpAndSettle();

    // assert
    expect(find.text('Something is missing'), findsOneWidget);
    expect(find.text('Team name cannot be empty'), findsOneWidget);
  });

  testWidgets('Adding a member keeps the composed model in charge of the whole form', (tester) async {
    // arrange
    await tester.pumpWidget(const MaterialApp(home: ComposedWithOwnInputsExample()));
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.widgetWithText(FloatingActionButton, '+'));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('Member #1'), findsOneWidget);
    expect(find.text('Member #2'), findsOneWidget);
  });

  testWidgets('Reset clears the team fields and every member at once', (tester) async {
    // arrange
    await tester.pumpWidget(const MaterialApp(home: ComposedWithOwnInputsExample()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FloatingActionButton, '+'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Team name'), 'A-team');
    await tester.enterText(find.widgetWithText(TextFormField, 'Motto (optional)'), 'Go go go');
    for (final field in find.widgetWithText(TextFormField, 'First name').evaluate()) {
      await tester.enterText(find.byWidget(field.widget), 'John');
    }
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.restart_alt));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('A-team'), findsNothing);
    expect(find.text('Go go go'), findsNothing);
    expect(find.text('John'), findsNothing, reason: 'every contained member is reset as well');
    expect(find.text('Something is missing'), findsOneWidget);
  });
}
