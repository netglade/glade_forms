import 'package:flutter_test/flutter_test.dart';
import 'package:glade_forms_devtools_extension/main.dart';

void main() {
  testWidgets('DevTools extension app builds', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const GladeFormsDevToolsExtension());
    await tester.pumpAndSettle();

    // Verify the app title is present
    expect(find.text('Glade Forms Inspector'), findsOneWidget);
  });

  testWidgets('Extension screen shows features list', (WidgetTester tester) async {
    await tester.pumpWidget(const GladeFormsDevToolsExtension());
    await tester.pumpAndSettle();

    // Verify feature descriptions are present
    expect(find.text('Features:'), findsOneWidget);
    expect(find.text('View active GladeModel instances'), findsOneWidget);
    expect(find.text('Inspect input values and validation states'), findsOneWidget);
    expect(find.text('Monitor form dirty/pure states'), findsOneWidget);
    expect(find.text('Real-time updates as forms change'), findsOneWidget);
  });

  testWidgets('Extension has proper branding', (WidgetTester tester) async {
    await tester.pumpWidget(const GladeFormsDevToolsExtension());
    await tester.pumpAndSettle();

    expect(find.text('Glade Forms DevTools Extension'), findsOneWidget);
    expect(find.text('Inspect and debug your glade_forms models'), findsOneWidget);
  });
}
