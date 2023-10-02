import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UsecaseContainer extends HookWidget {
  final Widget child;
  final String shortDescription;
  final String? description;

  const UsecaseContainer({
    required this.child,
    required this.shortDescription,
    super.key,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        body: SizedBox(
          height: constraints.maxHeight,
          child: Stack(
            children: [
              child,
              // SizedBox(
              //   height: 180,
              //   child: ExpansionTile(
              //     initiallyExpanded: expanded.value,
              //     title: Markdown(data: shortDescription),
              //     onExpansionChanged: (v) => expanded.value = v,
              //     children: [if (description case final x?) Markdown(data: x)],
              //   ),
              // ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
                  child: SizedBox(
                    width: double.infinity,
                    child: switch (description) {
                      final x? => Markdown(data: x),
                      _ => null,
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
