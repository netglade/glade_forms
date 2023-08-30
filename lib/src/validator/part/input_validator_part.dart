// ignore: one_member_abstracts, abstract class needed
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

abstract class InputValidatorPart<T> {
  // ignore: no-object-declaration, localeKey can be any object
  final Object? localeKey;

  const InputValidatorPart({this.localeKey});

  GenericValidatorError<T>? validate(T? value, {required Object? extra});
}
