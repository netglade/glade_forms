import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Extension Package Configuration', () {
    test('pubspec.yaml exists and is valid', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(() => loadYaml(content), returnsNormally);
    });

    test('pubspec.yaml has required dependencies', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final dependencies = yaml['dependencies'] as YamlMap;
      
      expect(dependencies.containsKey('devtools_extensions'), isTrue,
          reason: 'Extension must depend on devtools_extensions');
      expect(dependencies.containsKey('flutter'), isTrue,
          reason: 'Extension must depend on flutter');
      expect(dependencies.containsKey('glade_forms'), isTrue,
          reason: 'Extension must depend on glade_forms');
    });

    test('pubspec.yaml has correct SDK constraint', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      final environment = yaml['environment'] as YamlMap;
      final sdk = environment['sdk'] as String;
      
      // Should allow range of versions
      expect(sdk.contains('>='), isTrue, 
          reason: 'SDK constraint should use >= for minimum version');
      expect(sdk.contains('<'), isTrue,
          reason: 'SDK constraint should have upper bound');
    });

    test('main.dart exists', () {
      final file = File('lib/main.dart');
      expect(file.existsSync(), isTrue,
          reason: 'Extension must have lib/main.dart entry point');
    });

    test('web/index.html exists', () {
      final file = File('web/index.html');
      expect(file.existsSync(), isTrue,
          reason: 'Extension must have web/index.html for web build');
    });

    test('README.md exists and mentions architecture', () {
      final file = File('README.md');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content.contains('separate package'), isTrue,
          reason: 'README should explain architecture decision');
      expect(content.contains('build'), isTrue,
          reason: 'README should mention how to build');
    });
  });
}
