import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UsecaseContainer extends StatelessWidget {
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
            tabs: [
              const Tab(text: 'Live Preview', icon: Icon(Icons.live_tv)),
              if (className != null) const Tab(text: 'Example code', icon: Icon(Icons.code)),
              if (description != null) const Tab(text: 'Notes', icon: Icon(Icons.notes)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: child),
            if (className case final classNameX?) _CodeSample(fileName: classNameX),
            if (description case final descriptionX?) Markdown(data: descriptionX),
          ],
        ),
      ),
    );
  }
}

class _CodeSample extends HookWidget {
  final String fileName;
  const _CodeSample({required this.fileName});

  @override
  Widget build(BuildContext context) {
    final getFileContentFutureMemo = useMemoized(_getFileContent);
    final getFileFuture = useFuture(getFileContentFutureMemo);

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
                    // ignore: avoid-non-null-assertion, ok here
                    getFileFuture.data!,
                    padding: const EdgeInsets.all(10),
                    language: 'dart',
                    theme: githubTheme,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton.icon(
                    // ignore: prefer-extracting-callbacks, ok here.
                    onPressed: () {
                      // ignore: avoid-async-call-in-sync-function, avoid-non-null-assertion , ok here
                      Clipboard.setData(ClipboardData(text: getFileFuture.data!));
                      final _ = ScaffoldMessenger.of(context)
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

  Future<String> _getFileContent() {
    return rootBundle.loadString('lib/usecases/$fileName');
  }
}
