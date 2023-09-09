import 'package:formz/formz.dart';

/// Base input with value of type [TInput] and validation error of type [TError].
/// Provides [translate] method for translating its error.
abstract class BaseInput<TInput, TError> extends FormzInput<TInput, TError> {
  const BaseInput.asDirty(super.value) : super.dirty();

  const BaseInput.dirty(super.value) : super.dirty();

  const BaseInput.pure(super.value) : super.pure();

  // ignore: avoid-dynamic, error can be anything
  String? translate({String delimiter = '.', dynamic customError}) => error?.toString();
}
