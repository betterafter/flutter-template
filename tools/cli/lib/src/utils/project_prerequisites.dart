import 'dart:io' show File, stdout;

import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

import 'file_writer.dart';
import 'paths.dart';
import 'pubspec_editor.dart';

class PrerequisitesResult {
  const PrerequisitesResult({
    this.createdFiles = const [],
    this.updatedFiles = const [],
    this.addedDependencies = const [],
  });

  final List<String> createdFiles;
  final List<String> updatedFiles;
  final List<String> addedDependencies;

  bool get hasChanges =>
      createdFiles.isNotEmpty ||
      updatedFiles.isNotEmpty ||
      addedDependencies.isNotEmpty;
}

class ProjectPrerequisites {
  const ProjectPrerequisites(this._writer);

  final FileWriter _writer;

  static const _templateCoreFiles = [
    'domain/lib/core/data_state.dart',
    'data/lib/core/network/remote.dart',
    'data/lib/core/network/remote_failure.dart',
    'data/lib/core/network/network_module.dart',
    'data/lib/core/network/interceptors/logging_interceptor.dart',
    'data/lib/core/network/interceptors/error_interceptor.dart',
  ];

  Future<PrerequisitesResult> ensure(ProjectPaths project) async {
    final templatesRoot = p.join(await templateRoot(), 'init', 'packages');
    final createdFiles = <String>[];
    final updatedFiles = <String>[];

    for (final relative in _templateCoreFiles) {
      final source = p.join(templatesRoot, relative);
      final destination = p.join(project.packagesDir, relative);
      final created = await _writer.copyFileIfAbsent(
        source: source,
        destination: destination,
      );
      if (created) {
        createdFiles.add(p.relative(destination, from: project.root));
      }
    }

    final buildYamlPath = project.dataPackage('build.yaml');
    final buildYamlChange = await _ensureDataBuildYaml(
      templatesRoot: templatesRoot,
      buildYamlPath: buildYamlPath,
      project: project,
    );
    if (buildYamlChange == _BuildYamlChange.created) {
      createdFiles.add(p.relative(buildYamlPath, from: project.root));
    } else if (buildYamlChange == _BuildYamlChange.updated) {
      updatedFiles.add(p.relative(buildYamlPath, from: project.root));
    }

    final pubspecPath = project.dataPackage('pubspec.yaml');
    final pubspecAdded = await PubspecEditor().ensureDataPackageDependencies(
      pubspecPath,
    );
    final pubspecRelative = p.relative(pubspecPath, from: project.root);
    final addedDependencies = pubspecAdded
        .map((name) => '$pubspecRelative → $name')
        .toList();

    return PrerequisitesResult(
      createdFiles: createdFiles,
      updatedFiles: updatedFiles,
      addedDependencies: addedDependencies,
    );
  }

  Future<_BuildYamlChange> _ensureDataBuildYaml({
    required String templatesRoot,
    required String buildYamlPath,
    required ProjectPaths project,
  }) async {
    final file = File(buildYamlPath);
    if (!file.existsSync()) {
      await _writer.copyFileIfAbsent(
        source: p.join(templatesRoot, 'data/build.yaml'),
        destination: buildYamlPath,
      );
      return _BuildYamlChange.created;
    }

    final content = await file.readAsString();
    if (content.contains('retrofit_generator')) {
      return _BuildYamlChange.unchanged;
    }

    final editor = YamlEditor(content);
    _ensureMap(editor, ['targets', r'$default', 'builders']);
    editor.update(
      ['targets', r'$default', 'builders', 'retrofit_generator|retrofit_generator'],
      {
        'enabled': true,
        'generate_for': ['lib/data/**/api/*.dart'],
      },
    );
    await file.writeAsString(editor.toString());
    return _BuildYamlChange.updated;
  }

  void _ensureMap(YamlEditor editor, List<String> path) {
    try {
      if (editor.parseAt(path).value == null) {
        editor.update(path, <String, dynamic>{});
      }
    } catch (_) {
      editor.update(path, <String, dynamic>{});
    }
  }
}

enum _BuildYamlChange { unchanged, created, updated }

void printPrerequisitesResult(PrerequisitesResult result) {
  if (!result.hasChanges) {
    stdout.writeln('원격 데이터 레이어 필수 항목이 이미 모두 적용되어 있습니다.');
    return;
  }

  stdout.writeln('원격 데이터 레이어 필수 항목을 적용했습니다:');
  for (final file in result.createdFiles) {
    stdout.writeln('  + $file');
  }
  for (final file in result.updatedFiles) {
    stdout.writeln('  ~ $file');
  }
  for (final dependency in result.addedDependencies) {
    stdout.writeln('  + $dependency');
  }
}
