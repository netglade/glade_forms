
// abstract class GenericFormModel extends ChangeNotifier with FormzMixin, GenericInputsFormzMixin {
//   @protected
//   void updateInput<INPUT extends GenericInput<T>, T>(INPUT input, T value, void Function(INPUT v) assign) {
//     if (input.value == value) return;

//     assign(input.asDirty(value) as INPUT);
//     notifyListeners();
//   }
// }
