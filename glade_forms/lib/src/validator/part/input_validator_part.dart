// ignore: one_member_abstracts, abstract class needed
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

abstract class InputValidatorPart<T> {
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  const InputValidatorPart({this.key});

  GenericValidatorError<T>? validate(T? value, {required Object? extra});
}
