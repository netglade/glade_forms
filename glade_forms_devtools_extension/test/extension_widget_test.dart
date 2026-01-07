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

  testWidgets('Extension shows service unavailable message when not connected',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GladeFormsDevToolsExtension());
    await tester.pumpAndSettle();

    // Should show service unavailable message
    expect(find.text('Service Not Available'), findsOneWidget);
  });

  testWidgets('Extension has refresh button', (WidgetTester tester) async {
    await tester.pumpWidget(const GladeFormsDevToolsExtension());
    await tester.pumpAndSettle();

    // Find refresh button
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
