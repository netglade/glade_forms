// ignore_for_file: cascade_invocations

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _RowModel extends GladeModel {
  late GladeStringInput name;

  @override
  List<GladeInput<Object?>> get inputs => [name];

  @override
  void initialize() {
    name = GladeStringInput(value: '', inputKey: 'name');

    super.initialize();
  }
}

class _ComposedModel extends GladeComposedModel<_RowModel> {
  _ComposedModel([super.initialModels]);
}

class _NotificationCounter {
  int count = 0;

  void increment() => count++;
}

void main() {
  setUp(GladeForms.initialize);

  test('addModel notifies listeners by default', () {
    // arrange
    final composed = _ComposedModel();
    final counter = _NotificationCounter();
    composed.addListener(counter.increment);

    // act
    composed.addModel(_RowModel());

    // assert
    expect(counter.count, equals(1));
    expect(composed.models, hasLength(1));
  });

  test('addModel with shouldNotify false does not notify listeners', () {
    // arrange
    final composed = _ComposedModel();
    final model = _RowModel();
    final counter = _NotificationCounter();
    composed.addListener(counter.increment);

    // act
    composed.addModel(model, shouldNotify: false);

    // assert
    expect(counter.count, isZero);
    expect(composed.models, equals([model]));
  });

  test('Silently added model still propagates its changes', () {
    // arrange
    final composed = _ComposedModel();
    final model = _RowModel();
    final counter = _NotificationCounter();

    composed.addModel(model, shouldNotify: false);
    composed.addListener(counter.increment);

    // act
    model.name.value = 'John';

    // assert
    expect(counter.count, isNonZero);
    expect(composed.isDirty, isTrue);
  });

  test('removeModel notifies listeners by default', () {
    // arrange
    final model = _RowModel();
    final composed = _ComposedModel([model]);
    final counter = _NotificationCounter();
    composed.addListener(counter.increment);

    // act
    composed.removeModel(model);

    // assert
    expect(counter.count, equals(1));
    expect(composed.models, isEmpty);
  });

  test('removeModel with shouldNotify false does not notify listeners', () {
    // arrange
    final model = _RowModel();
    final composed = _ComposedModel([model]);
    final counter = _NotificationCounter();
    composed.addListener(counter.increment);

    // act
    composed.removeModel(model, shouldNotify: false);
    model.name.value = 'John';

    // assert
    expect(counter.count, isZero);
    expect(composed.models, isEmpty);
  });

  test('Models passed to constructor are registered', () {
    // arrange
    final model = _RowModel();

    // act
    final composed = _ComposedModel([model]);

    // assert
    expect(composed.models, equals([model]));
    expect(composed.isPure, isTrue);
  });
}
