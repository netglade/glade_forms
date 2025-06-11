// extension ObjectEx on Object? {
//   T? castOrNull<T>() => this is T ? this as T : null;

//   T cast<T>() => this as T;
// }

class ObjectHelper {
  static T? castOrNull<T>(Object? object) => object is T ? object : null;

  static T cast<T>(Object? object) => object as T;
}
