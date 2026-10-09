import 'package:glade_forms/src/utils/value_equality.dart';
import 'package:test/test.dart';

void main() {
  test('identical values are equal', () {
    // arrange
    final value = Object();

    // act
    final result = ValueEquality.equals(value, value);

    // assert
    expect(result, isTrue);
  });

  test('primitive values compare with ==', () {
    // arrange
    const a = 1;
    const b = 2;

    // act
    final same = ValueEquality.equals(a, a);
    final different = ValueEquality.equals(a, b);
    final bothNull = ValueEquality.equals<String?>(null, null);
    final oneNull = ValueEquality.equals<String?>('a', null);

    // assert
    expect(same, isTrue);
    expect(different, isFalse);
    expect(bothNull, isTrue);
    expect(oneNull, isFalse);
  });

  test('collections compare deeply', () {
    // arrange
    final list = [1, 2];
    final map = {'a': 1};
    final set = {1, 2};

    // act
    final sameList = ValueEquality.equals(list, [1, 2]);
    final reorderedList = ValueEquality.equals(list, [2, 1]);
    final sameMap = ValueEquality.equals(map, {'a': 1});
    final reorderedSet = ValueEquality.equals(set, {2, 1});

    // assert
    expect(sameList, isTrue);
    expect(reorderedList, isFalse);
    expect(sameMap, isTrue);
    expect(reorderedSet, isTrue);
  });
}
