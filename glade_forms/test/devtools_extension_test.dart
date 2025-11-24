import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('DevTools Extension Configuration', () {
    test('devtools_options.yaml exists in package root', () {
      final file = File('devtools_options.yaml');
      expect(file.existsSync(), isTrue, reason: 'devtools_options.yaml should exist');
    });

    test('devtools_options.yaml is valid YAML', () {
      final file = File('devtools_options.yaml');
      final content = file.readAsStringSync();
      
      expect(() => loadYaml(content), returnsNormally, reason: 'Should be valid YAML');
    });

    test('extension/config.yaml exists', () {
      final file = File('extension/config.yaml');
      expect(file.existsSync(), isTrue, reason: 'extension/config.yaml should exist');
    });

    test('extension/config.yaml has required fields', () {
      final file = File('extension/config.yaml');
      final content = file.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      expect(yaml['name'], equals('glade_forms'), reason: 'Extension name should be glade_forms');
      expect(yaml['description'], isNotNull, reason: 'Extension should have a description');
      expect(yaml['version'], isNotNull, reason: 'Extension should have a version');
      expect(yaml['devtoolsExtensionPath'], isNotNull, reason: 'Extension should specify path');
    });

    test('extension/config.yaml path is correct', () {
      final file = File('extension/config.yaml');
      final content = file.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final path = yaml['devtoolsExtensionPath'] as String;
      
      // Path should be relative and point to devtools/build/
      expect(path, equals('devtools/build/'), 
        reason: 'Extension path should match the build output location');
    });

    test('extension directory structure exists', () {
      final extensionDir = Directory('extension');
      expect(extensionDir.existsSync(), isTrue, reason: 'extension/ directory should exist');

      final devtoolsDir = Directory('extension/devtools');
      expect(devtoolsDir.existsSync(), isTrue, reason: 'extension/devtools/ directory should exist');
    });

    test('extension/README.md exists and is informative', () {
      final file = File('extension/README.md');
      expect(file.existsSync(), isTrue, reason: 'extension/README.md should exist');

      final content = file.readAsStringSync();
      expect(content.contains('DevTools Extension'), isTrue);
      expect(content.contains('build'), isTrue, 
        reason: 'README should mention how to build');
    });
  });
}
