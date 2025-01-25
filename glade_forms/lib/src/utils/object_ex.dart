extension ObjectEx on Object? {
  T? castOrNull<T>() => this is T ? this as T : null;

  T cast<T>() => this as T;
}
