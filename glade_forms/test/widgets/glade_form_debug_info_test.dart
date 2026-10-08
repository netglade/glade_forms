import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glade_forms/glade_forms.dart' hide Builder;

class _TeamModel extends GladeComposedModel<_MemberModel> {
  late GladeStringInput teamName;

  @override
  List<GladeInput<Object?>> get inputs => [teamName];

  _TeamModel([super.initialModels]);

  @override
  void initialize() {
    teamName = GladeStringInput(value: 'A-team', inputKey: 'teamName');

    super.initialize();
  }
}

class _MemberModel extends GladeModel {
  late GladeStringInput firstName;

  @override
  List<GladeInput<Object?>> get inputs => [firstName];

  @override
  void initialize() {
    firstName = GladeStringInput(value: '', inputKey: 'firstName', validator: (v) => (v..notEmpty()).build());

    super.initialize();
  }
}

/// Taps 'open' to show the debug info modal for the model under test.
class _ModalOpener<M extends GladeInputsOwner> extends StatelessWidget {
  final M model;

  const _ModalOpener({required this.model});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (builderContext) => ElevatedButton(
            onPressed: () => GladeFormDebugInfoModal.show(builderContext, model),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }
}

void main() {
  setUp(GladeForms.initialize);

  testWidgets('GladeFormDebugInfo renders own inputs of a composed model', (tester) async {
    // arrange
    final team = _TeamModel([_MemberModel()]);
    addTearDown(team.dispose);

    // act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GladeFormBuilder<_TeamModel>.value(
            value: team,
            builder: (context, model, child) => const GladeFormDebugInfo<_TeamModel>(),
          ),
        ),
      ),
    );

    // assert
    expect(find.text('teamName'), findsOneWidget);
    expect(find.textContaining('Contained models: 1'), findsOneWidget);
  });

  testWidgets('GladeFormDebugInfoModal.show finds the model it was given', (tester) async {
    // arrange
    final team = _TeamModel([_MemberModel()]);
    addTearDown(team.dispose);

    await tester.pumpWidget(_ModalOpener(model: team));

    // act
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // assert
    expect(tester.takeException(), isNull);
    expect(find.text('teamName'), findsOneWidget);
  });

  testWidgets('GladeFormDebugInfoModal.show works for a plain model too', (tester) async {
    // arrange
    final member = _MemberModel();
    addTearDown(member.dispose);

    await tester.pumpWidget(_ModalOpener(model: member));

    // act
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // assert
    expect(tester.takeException(), isNull);
    expect(find.text('firstName'), findsOneWidget);
  });
}
