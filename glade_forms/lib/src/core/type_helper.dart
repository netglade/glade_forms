class TypeHelper {
  static bool typesEqual<T1, T2>() => T1 == T2;

  static bool typeIsStringOrNullabeString<T>() => typesEqual<T, String>() || typesEqual<T, String?>();
}
