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

  Future<List<String>> ensureDataPackageDependencies(String pubspecPath) async {
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      throw StateError('pubspec.yaml을 찾을 수 없습니다: $pubspecPath');
    }

    final editor = YamlEditor(await file.readAsString());
    final added = <String>[];

    _ensureMap(editor, ['dependencies']);
    _ensureMap(editor, ['dev_dependencies']);

    const dependencies = {
      'dio': '^5.7.0',
      'retrofit': '^4.7.0',
      'injectable': '^2.5.0',
      'get_it': '^8.0.3',
      'build_runner': '^2.6.0',
      'source_gen': '^4.0.0',
    };

    const devDependencies = {
      'injectable_generator': '^2.5.0',
      'retrofit_generator': '^10.0.0',
      'build': '^4.0.0',
      'glob': '^2.1.2',
    };

    for (final entry in dependencies.entries) {
      if (_ensureKeyValue(
        editor,
        section: 'dependencies',
        name: entry.key,
        value: entry.value,
      )) {
        added.add(entry.key);
      }
    }

    for (final entry in devDependencies.entries) {
      if (_ensureKeyValue(
        editor,
        section: 'dev_dependencies',
        name: entry.key,
        value: entry.value,
      )) {
        added.add(entry.key);
      }
    }

    if (added.isNotEmpty) {
      await file.writeAsString(editor.toString());
    }

    return added;
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

  bool _ensureKeyValue(
    YamlEditor editor, {
    required String section,
    required String name,
    required String value,
  }) {
    final keyPath = [section, name];
    if (_tryParseAt(editor, keyPath) == null) {
      editor.update(keyPath, value);
      return true;
    }
    return false;
  }

  Object? _tryParseAt(YamlEditor editor, List<String> path) {
    try {
      return editor.parseAt(path).value;
    } catch (_) {
      return null;
    }
  }
}
