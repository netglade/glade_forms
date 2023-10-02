import 'package:glade_forms/src/core/core.dart';
import 'package:test/test.dart';

class _Model {
  late final GladeInput<bool> vipContent;

  late final GladeInput<int> age;

  _Model({bool enableVip = false}) {
    vipContent = GladeInput<bool>.required(value: enableVip, inputKey: 'vip');
    age = GladeInput<int>.create(
      (validator) => (validator
            ..satisfy((value, extra, dependencies) {
              final vipContentInput = dependencies.byKey('vip');

              if (vipContentInput == null) {
                return true;
              }

              if (vipContent.value) return value >= 18;

              return value < 18;
            }))
          .build(),
      value: 0,
      dependencies: () => [vipContent],
    );
  }

  _Model update(bool vip) => _Model(enableVip: vip);
}

void main() {
  test('Deps test - local mutable properties', () {
    var vipContent = GladeInput<bool>.required(value: false, inputKey: 'vip');

    final a = GladeInput<int>.create(
      (validator) => (validator
            ..satisfy((value, extra, dependencies) {
              final vipContentInput = dependencies.byKey('vip');

              if (vipContentInput == null) {
                return true;
              }

              if (vipContent.value) return value >= 18;

              return value < 18;
            }))
          .build(),
      value: 0,
      dependencies: () => [vipContent],
    );

    expect(a.isValid, isTrue);

    vipContent = vipContent.asDirty(true);

    expect(a.isValid, isFalse);
  });

  test('Deps test - local mutable inputs', () {
    final vipContent = GladeInput<bool>.required(value: false, inputKey: 'vip');

    final a = GladeInput<int>.create(
      (validator) => (validator
            ..satisfy((value, extra, dependencies) {
              final vipContentInput = dependencies.byKey('vip');

              if (vipContentInput == null) {
                return true;
              }

              if (vipContent.value) return value >= 18;

              return value < 18;
            }))
          .build(),
      value: 0,
      dependencies: () => [vipContent],
    );

    expect(a.isValid, isTrue);

    vipContent.value = true;

    expect(a.isValid, isFalse);
  });

  test('Deps test - immutable model', () {
    var model = _Model();

    expect(model.age.isValid, isTrue);

    model = model.update(true);
    expect(model.age.isValid, isFalse);
  });
}
