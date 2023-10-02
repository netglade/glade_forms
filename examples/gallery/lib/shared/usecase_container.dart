import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UsecaseContainer extends HookWidget {
  final Widget child;
  final String shortDescription;
  final String? description;
  final String? className;

  const UsecaseContainer({
    required this.child,
    required this.shortDescription,
    super.key,
    this.description,
    this.className,
  });

  @override
  Widget build(BuildContext context) {
    final tabLength = [child, className, description].where((x) => x != null).length;

    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shortDescription),
          bottom: TabBar(
            tabs: <Widget>[
              const Tab(text: 'Live Preview', icon: Icon(Icons.live_tv)),
              if (className != null) const Tab(text: 'Example code', icon: Icon(Icons.code)),
              if (description != null) const Tab(text: 'Notes', icon: Icon(Icons.notes)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(child: child),
            if (className case final classNameX?) _CodeSample(fileName: classNameX),
            if (description case final descriptionX?) Markdown(data: descriptionX),
          ],
        ),
      ),
    );

    // return LayoutBuilder(
    //   builder: (context, constraints) => Scaffold(
    //     body: SizedBox(
    //       height: constraints.maxHeight,
    //       child: Stack(
    //         children: [
    //           child,
    //           // SizedBox(
    //           //   height: 180,
    //           //   child: ExpansionTile(
    //           //     initiallyExpanded: expanded.value,
    //           //     title: Markdown(data: shortDescription),
    //           //     onExpansionChanged: (v) => expanded.value = v,
    //           //     children: [if (description case final x?) Markdown(data: x)],
    //           //   ),
    //           // ),
    //           Align(
    //             alignment: Alignment.bottomCenter,
    //             child: ConstrainedBox(
    //               constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
    //               child: SizedBox(
    //                 width: double.infinity,
    //                 child: switch (description) {
    //                   final x? => Markdown(data: x),
    //                   _ => null,
    //                 },
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class _CodeSample extends HookWidget {
  final String fileName;
  const _CodeSample({required this.fileName});

  Future<String> getFileContent() {
    return rootBundle.loadString('lib/usecases/$fileName');
  }

  @override
  Widget build(BuildContext context) {
    final f = useMemoized(getFileContent);
    final getFileFuture = useFuture(f);

    if (getFileFuture.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (getFileFuture.hasError) return Text(getFileFuture.error?.toString() ?? '???');

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                child: SelectionArea(
                  child: HighlightView(
                    getFileFuture.data!,
                    padding: const EdgeInsets.all(10),
                    language: 'dart',
                    theme: githubTheme,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: getFileFuture.data!));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Code copied to clipboad')));
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('Copy code'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
