import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/glade_model.dart';

/// Provides debug table displaying model's inputs and validation errors.
class GladeModelDebugInfo extends StatelessWidget {
  final GladeModel model;

  final bool showIsUnchanged;
  final bool showIsValid;
  final bool showValidationError;
  final bool showConversionError;
  final bool showValue;
  final bool showInitialValue;

  const GladeModelDebugInfo({
    required this.model,
    super.key,
    this.showIsUnchanged = true,
    this.showIsValid = true,
    this.showValidationError = true,
    this.showConversionError = true,
    this.showValue = false,
    this.showInitialValue = false,
  });

  const GladeModelDebugInfo.clean({
    required this.model,
    super.key,
    this.showIsUnchanged = false,
    this.showIsValid = false,
    this.showValidationError = false,
    this.showConversionError = false,
    this.showValue = false,
    this.showInitialValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DangerStrips(color1: Colors.black, color2: Colors.red, gap: 5),
          Text('Model isValid: ${model.isValid}'),
          Text('Model isUnchanged: ${model.isUnchanged}'),
          const SizedBox(height: 20),

          // Table.
          Table(
            border: TableBorder.symmetric(outside: const BorderSide()),
            children: [
              // Main header.
              TableRow(
                decoration: const BoxDecoration(color: Colors.black12),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Debug model info'),
                  ),
                  if (showIsUnchanged)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('IsUnchanged: ${model.isUnchanged}'),
                      ),
                    ),
                  if (showIsValid)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('IsValid: ${model.isValid}'),
                      ),
                    ),
                  if (showValidationError) const SizedBox(),
                  if (showConversionError) const SizedBox(),
                  if (showValue) const SizedBox(),
                  if (showInitialValue) const SizedBox(),
                ],
              ),

              // Inputs info note header.
              TableRow(
                decoration: const BoxDecoration(color: Colors.black12),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Inputs info'),
                  ),
                  if (showIsUnchanged) const SizedBox(),
                  if (showIsValid) const SizedBox(),
                  if (showValidationError) const SizedBox(),
                  if (showConversionError) const SizedBox(),
                  if (showValue) const SizedBox(),
                  if (showInitialValue) const SizedBox(),
                ],
              ),

              // Colums header.
              TableRow(
                decoration: const BoxDecoration(color: Colors.black12, border: Border(bottom: BorderSide())),
                children: [
                  const Center(child: Text('Input')),
                  if (showIsUnchanged) const Center(child: Text('isUnchanged')),
                  if (showIsValid) const Center(child: Text('isValid')),
                  if (showValidationError) const Center(child: Text('validation error')),
                  if (showConversionError) const Center(child: Text('Conversion error')),
                  if (showValue) const Center(child: Text('value')),
                  if (showInitialValue) const Center(child: Text('initialValue')),
                ],
              ),
              for (final x in model.inputs)
                TableRow(
                  children: [
                    Center(child: Text(x.inputKey)),
                    if (showIsUnchanged) Center(child: Text(x.isUnchanged.toString())),
                    if (showIsValid) Center(child: Text(x.isValid.toString())),
                    if (showValidationError) Center(child: Text(x.errorFormatted())),
                    if (showConversionError) Center(child: Text(x.hasConversionError.toString())),
                    if (showValue) Center(child: Text(x.value.toString())),
                    if (showInitialValue) Center(child: Text(x.initialValue.toString())),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          const _DangerStrips(color1: Colors.black, color2: Colors.red, gap: 5),
        ],
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

  List<Widget> getListOfStripes(int count) {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(children: getListOfStripes((constraints.maxWidth / 2).ceil()));
        },
      ),
    );
  }
}
