import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/glade_model.dart';

/// Provides debug table displaying model's inputs and validation errors.
class GladeModelDebugInfo extends StatelessWidget {
  final GladeModel model;

  const GladeModelDebugInfo({required this.model, super.key});

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
          Table(
            border: TableBorder.symmetric(outside: const BorderSide()),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.black12),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Debug model info'),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('IsValid: ${model.isValid}'),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('IsUnchanged: ${model.isUnchanged}'),
                    ),
                  ),
                  const SizedBox(),
                  const SizedBox(),
                ],
              ),
              const TableRow(
                decoration: BoxDecoration(color: Colors.black12),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Inputs info'),
                  ),
                  SizedBox(),
                  SizedBox(),
                  SizedBox(),
                  SizedBox(),
                ],
              ),
              const TableRow(
                decoration: BoxDecoration(color: Colors.black12, border: Border(bottom: BorderSide())),
                children: [
                  Center(child: Text('Input')),
                  Center(child: Text('isUnchanged')),
                  Center(child: Text('isValid')),
                  Center(child: Text('validation error')),
                  Center(child: Text('Conversion error')),
                ],
              ),
              for (final x in model.inputs)
                TableRow(
                  children: [
                    Center(child: Text(x.inputName)),
                    Center(child: Text(x.isUnchanged.toString())),
                    Center(child: Text(x.isValid.toString())),
                    Center(child: Text(x.errorFormatted())),
                    Center(child: Text(x.hasConversionError.toString())),
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
    // ignore: avoid-returning-widgets, it is ok here
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
