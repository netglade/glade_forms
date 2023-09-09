import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/variants/required_input.dart';
import 'package:test/test.dart';

class Model {
  late final RequiredInput<bool> vipContent;

  late final GenericInput<int> age;

  Model({bool enableVip = false}) {
    vipContent = RequiredInput<bool>.pure(value: enableVip, inputKey: 'vip');
    age = GenericInput<int>.create(
      (validator) => (validator
            ..satisfy((value, extra, dependencies) {
              final vipContentInput = dependencies.byKey('vip');

              if (vipContentInput == null) {
                print('dep null');

                return true;
              }

              print(vipContent.value);

              if (vipContent.value) return value >= 18;

              return value < 18;
            }))
          .build(),
      value: 0,
      dependencies: [vipContent],
    );
  }

  Model update(bool vip) => Model(enableVip: vip);
}

void main() {
  test('Deps test - local mutable properties', () {
    var vipContent = RequiredInput<bool>.pure(value: false, inputKey: 'vip');

    final a = GenericInput<int>.create(
      (validator) => (validator
            ..satisfy((value, extra, dependencies) {
              final vipContentInput = dependencies.byKey('vip');

              if (vipContentInput == null) {
                print('dep null');

                return true;
              }

              print(vipContent.value);

              if (vipContent.value) return value >= 18;

              return value < 18;
            }))
          .build(),
      value: 0,
      dependencies: [vipContent],
    );

    expect(a.isValid, isTrue);

    vipContent = vipContent.asDirty(true);

    expect(a.isValid, isFalse);
  });

  test('Deps test - immutable model', () {
    var model = Model();

    expect(model.age.isValid, isTrue);

    model = model.update(true);
    expect(model.age.isValid, isFalse);
  });
}
