import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/validator/validator.dart';

// /// Base input with value of type [TInput] and validation error of type [TError].
// /// Provides [translate] method for translating its error.
// abstract class BaseInput<TInput, TError> extends FormzInput<TInput, TError> {
//   const BaseInput.asDirty(super.value) : super.dirty();

//   const BaseInput.dirty(super.value) : super.dirty();

//   const BaseInput.pure(super.value) : super.pure();

//   // ignore: avoid-dynamic, error can be anything
//   String? translate({String delimiter = '.', dynamic customError}) => error?.toString();
// }

typedef ValueComparator<T> = bool Function(T? initial, T? value);

typedef TranslateError<T> = String Function(
  GenericValidatorError<T> error,
  Object? key,
  String defaultMessage, {
  required InputDependencies dependencies,
});

@immutable
abstract class GladeInputBase<T> {
  @protected
  final ValueComparator<T>? valueComparator;

  final String? inputKey;

  final T value;

  /// Initial value - does not change after creating.
  final T? initialValue;

  final bool isPure;

  final TranslateError<T>? translateError;

  @override
  int get hashCode => Object.hashAll([value, isPure]);

  ValidatorErrors<T>? get error => validator(value);

  bool get isUnchanged => (valueComparator?.call(initialValue, value) ?? value) == initialValue;

  bool get isValid => validator(value) == null;

  bool get isNotValid => !isValid;

  const GladeInputBase({
    required this.value,
    this.isPure = true,
    this.initialValue,
    this.valueComparator,
    this.inputKey,
    this.translateError,
  });

  const GladeInputBase.pure(
    T value, {
    T? initialValue,
    ValueComparator<T>? comparator,
  }) : this(
          value: value,
          initialValue: initialValue ?? value,
          valueComparator: comparator,
        );

  const GladeInputBase.dirty(
    T value, {
    T? initialValue,
    ValueComparator<T>? comparator,
  }) : this(
          value: value,
          isPure: false,
          initialValue: initialValue,
          valueComparator: comparator,
        );

  GladeInputBase<T> asDirty(T value);

  GladeInputBase<T> asPure(T value);

  ValidatorErrors<T>? validator(T value);

  String? translate({String delimiter = '.', Object? customError}) => error?.toString();

  String errorFormatted({String delimiter = '|'}) => error?.errors.map((e) => e.toString()).join(delimiter) ?? '';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;

    return other is GladeInputBase<T> && other.value == value && other.isPure == isPure;
  }
}

class _GladeForms {
  // ignore: avoid-dynamic, we allow mix of inputs.
  static bool validate(List<GladeInputBase<dynamic>> inputs) {
    return inputs.every((input) => input.isValid);
  }

  // ignore: avoid-dynamic, we allow mix of inputs.
  static bool isPure(List<GladeInputBase<dynamic>> inputs) {
    return inputs.every((input) => input.isPure);
  }
}

mixin GladeFormMixin {
  bool get isValid => _GladeForms.validate(inputs);

  bool get isNotValid => !isValid;

  bool get isPure => _GladeForms.isPure(inputs);

  bool get isDirty => !isPure;

  // ignore: avoid-dynamic, we allow mix of inputs.
  List<GladeInputBase<dynamic>> get inputs;

  /// Formats errors from `inputs`.
  String get formattedValidationErrors => inputs.map((e) {
        if (e.error?.errors.isNotEmpty ?? false) {
          return '${e.inputKey ?? e.runtimeType} - ${e.errorFormatted()}';
        }

        return '${e.inputKey ?? e.runtimeType} - VALID';
      }).join('\n');

  // ignore: avoid-dynamic, error from Formz is dynamic
  List<dynamic> get errors => inputs.map((e) => e.error).toList();
}

abstract class GenericModel with GladeFormMixin {}
