import 'dart:io';

import 'package:yaml_edit/yaml_edit.dart';

class PubspecEditor {
  Future<void> ensureCleanArchDependencies(String pubspecPath) async {
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      throw StateError('pubspec.yaml을 찾을 수 없습니다: $pubspecPath');
    }

    final editor = YamlEditor(await file.readAsString());

    _ensureMap(editor, ['dependencies']);
    _ensureMap(editor, ['dev_dependencies']);

    _ensurePathDependency(
      editor,
      section: 'dependencies',
      name: 'domain',
      path: './packages/domain',
    );
    _ensurePathDependency(
      editor,
      section: 'dependencies',
      name: 'data',
      path: './packages/data',
    );
    _ensurePathDependency(
      editor,
      section: 'dependencies',
      name: 'presentation',
      path: './packages/presentation',
    );
    _ensureKeyValue(
      editor,
      section: 'dependencies',
      name: 'injectable',
      value: '^2.5.0',
    );
    _ensureKeyValue(
      editor,
      section: 'dependencies',
      name: 'get_it',
      value: '^8.0.3',
    );
    _ensureKeyValue(
      editor,
      section: 'dependencies',
      name: 'flutter_riverpod',
      value: '^2.5.1',
    );

    _ensureKeyValue(
      editor,
      section: 'dev_dependencies',
      name: 'build_runner',
      value: '^2.4.12',
    );
    _ensureKeyValue(
      editor,
      section: 'dev_dependencies',
      name: 'melos',
      value: '^6.3.2',
    );
    _ensureKeyValue(
      editor,
      section: 'dev_dependencies',
      name: 'injectable_generator',
      value: '^2.5.0',
    );

    await file.writeAsString(editor.toString());
  }

  void _ensureMap(YamlEditor editor, List<String> path) {
    if (_tryParseAt(editor, path) == null) {
      editor.update(path, <String, dynamic>{});
    }
  }

  void _ensurePathDependency(
    YamlEditor editor, {
    required String section,
    required String name,
    required String path,
  }) {
    final keyPath = [section, name];
    final existing = _tryParseAt(editor, keyPath);

    if (existing == null) {
      editor.update(keyPath, {'path': path});
      return;
    }

    if (existing is Map && existing['path'] == path) {
      return;
    }

    editor.update(keyPath, {'path': path});
  }

  void _ensureKeyValue(
    YamlEditor editor, {
    required String section,
    required String name,
    required String value,
  }) {
    final keyPath = [section, name];
    if (_tryParseAt(editor, keyPath) == null) {
      editor.update(keyPath, value);
    }
  }

  Object? _tryParseAt(YamlEditor editor, List<String> path) {
    try {
      return editor.parseAt(path).value;
    } catch (_) {
      return null;
    }
  }
}
