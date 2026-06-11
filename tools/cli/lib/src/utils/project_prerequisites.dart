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

  Future<PrerequisitesResult> ensure(
    ProjectPaths project, {
    bool force = false,
  }) async {
    final templatesRoot = p.join(await templateRoot(), 'init', 'packages');
    final createdFiles = <String>[];
    final updatedFiles = <String>[];

    for (final relative in _templateCoreFiles) {
      final source = p.join(templatesRoot, relative);
      final destination = p.join(project.packagesDir, relative);
      final relativeDestination = p.relative(destination, from: project.root);
      final exists = File(destination).existsSync();

      if (force) {
        await _writer.copyFile(
          source: source,
          destination: destination,
          force: true,
        );
        if (exists) {
          updatedFiles.add(relativeDestination);
        } else {
          createdFiles.add(relativeDestination);
        }
        continue;
      }

      final created = await _writer.copyFileIfAbsent(
        source: source,
        destination: destination,
      );
      if (created) {
        createdFiles.add(relativeDestination);
      }
    }

    final buildYamlPath = project.dataPackage('build.yaml');
    final buildYamlRelative = p.relative(buildYamlPath, from: project.root);
    if (force) {
      final exists = File(buildYamlPath).existsSync();
      await _writer.copyFile(
        source: p.join(templatesRoot, 'data/build.yaml'),
        destination: buildYamlPath,
        force: true,
      );
      if (exists) {
        updatedFiles.add(buildYamlRelative);
      } else {
        createdFiles.add(buildYamlRelative);
      }
    } else {
      final buildYamlChange = await _ensureDataBuildYaml(
        templatesRoot: templatesRoot,
        buildYamlPath: buildYamlPath,
      );
      if (buildYamlChange == _BuildYamlChange.created) {
        createdFiles.add(buildYamlRelative);
      } else if (buildYamlChange == _BuildYamlChange.updated) {
        updatedFiles.add(buildYamlRelative);
      }
    }

    final moduleGeneratorPath = project.dataPackage('lib/module.generator.dart');
    final moduleGeneratorRelative =
        p.relative(moduleGeneratorPath, from: project.root);
    final moduleGeneratorExists = File(moduleGeneratorPath).existsSync();
    if (await _ensureDataModuleGenerator(
      templatesRoot: templatesRoot,
      moduleGeneratorPath: moduleGeneratorPath,
      force: force,
    )) {
      if (moduleGeneratorExists) {
        updatedFiles.add(moduleGeneratorRelative);
      } else {
        createdFiles.add(moduleGeneratorRelative);
      }
    }

    final presentationBuildYamlPath =
        project.presentationPackage('build.yaml');
    final presentationBuildYamlRelative =
        p.relative(presentationBuildYamlPath, from: project.root);
    if (force) {
      final exists = File(presentationBuildYamlPath).existsSync();
      await _writer.copyFile(
        source: p.join(templatesRoot, 'presentation/build.yaml'),
        destination: presentationBuildYamlPath,
        force: true,
      );
      if (exists) {
        updatedFiles.add(presentationBuildYamlRelative);
      } else {
        createdFiles.add(presentationBuildYamlRelative);
      }
    } else if (await _writer.copyFileIfAbsent(
      source: p.join(templatesRoot, 'presentation/build.yaml'),
      destination: presentationBuildYamlPath,
    )) {
      createdFiles.add(presentationBuildYamlRelative);
    }

    final pubspecEditor = PubspecEditor();
    final addedDependencies = <String>[];

    final dataPubspecPath = project.dataPackage('pubspec.yaml');
    final dataPubspecRelative = p.relative(dataPubspecPath, from: project.root);
    addedDependencies.addAll(
      (await pubspecEditor.ensureDataPackageDependencies(dataPubspecPath))
          .map((name) => '$dataPubspecRelative → $name'),
    );

    final presentationPubspecPath =
        project.presentationPackage('pubspec.yaml');
    final presentationPubspecRelative =
        p.relative(presentationPubspecPath, from: project.root);
    addedDependencies.addAll(
      (await pubspecEditor.ensurePresentationPackageDependencies(
        presentationPubspecPath,
      )).map((name) => '$presentationPubspecRelative → $name'),
    );

    return PrerequisitesResult(
      createdFiles: createdFiles,
      updatedFiles: updatedFiles,
      addedDependencies: addedDependencies,
    );
  }

  Future<bool> _ensureDataModuleGenerator({
    required String templatesRoot,
    required String moduleGeneratorPath,
    required bool force,
  }) async {
    final file = File(moduleGeneratorPath);
    if (!force && file.existsSync()) {
      final content = await file.readAsString();
      if (content.contains("endsWith('.g.dart')")) {
        return false;
      }
    }

    await _writer.copyFile(
      source: p.join(templatesRoot, 'data/lib/module.generator.dart'),
      destination: moduleGeneratorPath,
      force: true,
    );
    return true;
  }

  Future<_BuildYamlChange> _ensureDataBuildYaml({
    required String templatesRoot,
    required String buildYamlPath,
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
