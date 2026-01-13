typedef MetadataValueBuilder<T> = String Function(T value);

class GladeMetaData<T> {
  final T value;

  /// If true, value will be shown with colorized background to indicate white space or empty value.
  final bool shouldIndicateStringValue;
  final MetadataValueBuilder<T>? valueBuilder;

  const GladeMetaData({
    required this.value,
    required this.shouldIndicateStringValue,
    this.valueBuilder,
  });

  @override
  String toString() => valueBuilder?.call(value) ?? value.toString();
}
