import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/widgets/glade_form_builder.dart';

/// Provides debug table displaying model's inputs and validation errors.
class GladeFormDebugInfo<M extends GladeModel> extends StatelessWidget {
  /// Whether to show isUnchanged column.
  final bool showIsUnchanged;

  /// Whether to show isValid column.
  final bool showIsValid;

  /// Whether to show validation error column.
  final bool showValidationError;

  /// Whether to show conversion error column.
  final bool showConversionError;

  /// Whether to show value column.
  final bool showValue;

  /// Whether to show initialValue column.
  final bool showInitialValue;

  /// Whether to show controller.text column.
  final bool showControllerText;

  /// Inputs (defined by key) which are hidden from listing.
  final List<String> hiddenKeys;

  final bool scrollable;

  const GladeFormDebugInfo({
    super.key,
    this.showIsUnchanged = true,
    this.showIsValid = true,
    this.showValidationError = true,
    this.showConversionError = true,
    this.showValue = true,
    this.showInitialValue = true,
    this.showControllerText = false,
    this.hiddenKeys = const [],
    this.scrollable = true,
  });

  const GladeFormDebugInfo.clean({
    super.key,
    this.showIsUnchanged = false,
    this.showIsValid = false,
    this.showValidationError = false,
    this.showConversionError = false,
    this.showValue = false,
    this.showInitialValue = false,
    this.showControllerText = false,
    this.hiddenKeys = const [],
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GladeFormBuilder<M>(
      builder: (context, model, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DangerStrips(color1: Colors.black, color2: Colors.red, gap: 5),
              // Table.
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('IsValid:'),
                          _BoolIcon(value: model.isValid),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('isUnchanged:'),
                          _BoolIcon(value: model.isUnchanged),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    // ignore: prefer-extracting-callbacks, its ok.
                    onPressed: () {
                      final _ = showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                              const Text("Each column's value has tooltip. Use it to display full value."),
                              const Text('Bool values with black color mark untracked values within model.'),
                              const Row(
                                children: [
                                  Icon(Icons.check, color: Colors.green),
                                  Text('True value, tracked'),
                                ],
                              ),
                              const Row(
                                children: [
                                  Icon(Icons.close, color: Colors.red),
                                  Text('False value, tracked'),
                                ],
                              ),
                              const Row(
                                children: [
                                  Icon(Icons.check, color: Colors.black),
                                  Icon(Icons.close, color: Colors.black),
                                  Text('True/False untracked'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text('String value is annotated with colored background such as'),
                              const _StringValue(x: '    There is whitespace at the beginning.'),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.help),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              if (scrollable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _Table(
                    scrollable: scrollable,
                    showIsUnchanged: showIsUnchanged,
                    showIsValid: showIsValid,
                    showValidationError: showValidationError,
                    showConversionError: showConversionError,
                    showValue: showValue,
                    showInitialValue: showInitialValue,
                    showControllerText: showControllerText,
                    hiddenKeys: hiddenKeys,
                    model: model,
                  ),
                )
              else
                _Table(
                  scrollable: scrollable,
                  showIsUnchanged: showIsUnchanged,
                  showIsValid: showIsValid,
                  showValidationError: showValidationError,
                  showConversionError: showConversionError,
                  showValue: showValue,
                  showInitialValue: showInitialValue,
                  showControllerText: showControllerText,
                  hiddenKeys: hiddenKeys,
                  model: model,
                ),
              const SizedBox(height: 10),
              const _DangerStrips(color1: Colors.black, color2: Colors.red, gap: 5),
            ],
          ),
        );
      },
    );
  }
}

class _Table extends StatelessWidget {
  final bool scrollable;
  final bool showIsUnchanged;
  final bool showIsValid;
  final bool showValidationError;
  final bool showConversionError;
  final bool showValue;
  final bool showInitialValue;
  final bool showControllerText;
  final GladeModel model;
  final List<String> hiddenKeys;

  const _Table({
    required this.scrollable,
    required this.showIsUnchanged,
    required this.showIsValid,
    required this.showValidationError,
    required this.showConversionError,
    required this.showValue,
    required this.showInitialValue,
    required this.model,
    required this.hiddenKeys,
    required this.showControllerText,
  });

  @override
  Widget build(BuildContext context) {
    final inputs = model.inputs.where((element) => !hiddenKeys.contains(element.inputKey));
    final rowColor = Theme.of(context).colorScheme.surface;
    final alternativeRowColor =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark ? rowColor.lighten() : rowColor.darken();

    return Table(
      defaultColumnWidth: scrollable ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
      border: const TableBorder.symmetric(outside: BorderSide()),
      children: [
        // Columns header.
        TableRow(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor, border: const Border(bottom: BorderSide())),
          children: [
            const _ColumnHeader('Input'),
            if (showIsUnchanged) const _ColumnHeader('isUnchanged'),
            if (showIsValid) const _ColumnHeader('isValid'),
            if (showValidationError) const _ColumnHeader('Validation'),
            if (showConversionError) const _ColumnHeader('Conversion error'),
            if (showValue) const _ColumnHeader('value'),
            if (showInitialValue) const _ColumnHeader('initialValue'),
            if (showControllerText) const _ColumnHeader('controller.text'),
          ],
        ),
        for (final (index, x) in inputs.indexed)
          TableRow(
            decoration: BoxDecoration(
              color: index.isEven ? rowColor : alternativeRowColor,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: _RowValue(value: x.inputKey, wrap: true, center: false),
              ),
              if (showIsUnchanged) _RowValue(value: x.isUnchanged, tracked: x.trackUnchanged),
              if (showIsValid) _RowValue(value: x.isValid),
              if (showValidationError) _RowValue(value: x.errorFormatted()),
              if (showConversionError) _RowValue(value: x.hasConversionError),
              if (showValue) _RowValue(value: x.value, colorizedValue: true),
              if (showInitialValue) _RowValue(value: x.initialValue, colorizedValue: true),
              if (showControllerText) _RowValue(value: x.controller?.text, colorizedValue: true),
            ],
          ),
      ],
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final String label;

  const _ColumnHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(left: 10), child: Center(child: Text(label)));
  }
}

class _RowValue extends StatelessWidget {
  // ignore: no-object-declaration, can be any value.
  final Object? value;
  final bool tracked;
  final bool wrap;
  final bool center;
  final bool colorizedValue;

  const _RowValue({
    required this.value,
    this.wrap = false,
    this.tracked = true,
    this.center = true,
    this.colorizedValue = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) return const Center(child: Text('NULL'));

    if (value case final bool? x when x != null) {
      return _BoolIcon(value: x, colorize: tracked);
    }

    if (value case final String x when colorizedValue) {
      return Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Tooltip(
          message: x,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: _StringValue(x: x),
          ),
        ),
      );
    }

    return Align(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: Tooltip(
        message: value?.toString(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            value?.toString() ?? '',
            softWrap: wrap,
            overflow: wrap ? null : TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _StringValue extends StatelessWidget {
  final String? x;

  const _StringValue({required this.x});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 196, 222, 184)
          : const Color.fromARGB(255, 15, 46, 0),
      child: Text(
        x ?? '',
        //style: Theme.of(context).textTheme.bodyLarge?.copyWith(backgroundColor: ),
      ),
    );
  }
}

class _BoolIcon extends StatelessWidget {
  final bool value;
  final bool colorize;

  const _BoolIcon({required this.value, this.colorize = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        value ? Icons.check : Icons.close,
        size: 16,
        color: colorize ? (value ? Colors.green : Colors.red) : null,
      ),
    );
  }
}

class _DangerClipper extends CustomClipper<Path> {
  final double extent;

  const _DangerClipper({required this.extent});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, extent)
      ..lineTo(extent, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _DangerStrips extends StatelessWidget {
  final Color color1;
  final Color color2;
  final double gap;
  const _DangerStrips({
    required this.color1,
    required this.color2,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(children: _getListOfStripes((constraints.maxWidth / 2).ceil()));
        },
      ),
    );
  }

  List<Widget> _getListOfStripes(int count) {
    final stripes = <Widget>[];
    for (var i = 0; i < count; i++) {
      stripes.add(
        ClipPath(
          clipper: _DangerClipper(extent: i * gap),
          child: Container(color: (i.isEven ? color1 : color2)),
        ),
      );
    }

    return stripes;
  }
}

extension _PrivateColorEx on Color {
  /// Returns color darkened by [amount].
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Returns color lightened by [amount].
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
