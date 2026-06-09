import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../utils/file_writer.dart';
import '../utils/paths.dart';
import '../utils/process_runner.dart';
import '../utils/project_name_reader.dart';
import '../utils/pubspec_editor.dart';

class InitCommand extends Command<int> {
  InitCommand() {
    argParser.addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help: '이미 존재하는 파일을 덮어씁니다.',
    );
    argParser.addFlag(
      'skip-build',
      negatable: false,
      help: 'init 후 build_runner를 실행하지 않습니다.',
    );
  }

  @override
  String get name => 'init';

  @override
  String get description => 'Clean Architecture 프로젝트 구조를 생성합니다.';

  @override
  Future<int> run() async {
    final force = argResults!['force'] as bool;
    final skipBuild = argResults!['skip-build'] as bool;
    final project = ProjectPaths.fromCwd();

    if (!project.isFlutterProject) {
      stderr.writeln('현재 디렉터리에 Flutter 프로젝트(pubspec.yaml)가 없습니다.');
      stderr.writeln('먼저 `flutter create`로 프로젝트를 생성한 뒤 다시 실행해주세요.');
      return 1;
    }

    if (project.hasCleanArchStructure && !force) {
      stderr.writeln('이미 Clean Architecture 구조가 존재합니다.');
      stderr.writeln('덮어쓰려면 --force 옵션을 사용해주세요.');
      return 1;
    }

    final writer = FileWriter();
    final initRoot = p.join(templateRoot(), 'init');
    final created = <String>[];

    stdout.writeln('Clean Architecture 구조를 생성합니다...\n');

    await writer.copyDirectory(
      source: p.join(initRoot, 'packages'),
      destination: project.packagesDir,
      force: force,
    );
    created.add('packages/ (domain, data, presentation, design)');

    await writer.copyFile(
      source: p.join(initRoot, 'melos.yaml'),
      destination: project.melos,
      force: force,
    );
    created.add('melos.yaml');

    final projectName = await ProjectNameReader.read(project.pubspec);
    await writer.writeFile(
      path: p.join(project.root, 'lib', 'di.dart'),
      content: _diTemplate(projectName),
      force: force,
    );
    created.add('lib/di.dart');

    await PubspecEditor().ensureCleanArchDependencies(project.pubspec);
    created.add('pubspec.yaml (path 의존성 추가)');

    final mainPath = p.join(project.root, 'lib', 'main.dart');
    if (!File(mainPath).existsSync() || force) {
      await writer.writeFile(
        path: mainPath,
        content: _mainTemplate(projectName),
        force: true,
      );
      created.add('lib/main.dart');
    } else {
      stdout.writeln(
        'ℹ lib/main.dart는 기존 파일을 유지했습니다. configureDependencies() 호출을 직접 추가해주세요.',
      );
    }

    for (final item in created) {
      stdout.writeln('✓ $item');
    }

    if (!skipBuild) {
      stdout.writeln('\nbuild_runner를 실행합니다...');
      final runner = ProcessRunner();
      await runner.run('dart', ['pub', 'global', 'activate', 'melos']);
      await runner.run('melos', ['bootstrap'], workingDirectory: project.root);
      await runner.runBuildRunner(p.join(project.packagesDir, 'design'));
      await runner.runBuildRunner(p.join(project.packagesDir, 'domain'));
      await runner.runBuildRunner(p.join(project.packagesDir, 'data'));
      await runner.runBuildRunner(p.join(project.packagesDir, 'presentation'));
      await runner.runBuildRunner(project.root);
    }

    stdout.writeln('\n완료! 다음 명령으로 feature를 추가할 수 있습니다.');
    stdout.writeln('  flutter_clean_arch add feature payment --with-ui');
    if (!skipBuild) {
      stdout.writeln('\n의존성 설치와 코드 생성이 완료되었습니다.');
    } else {
      stdout.writeln('\n다음 명령을 실행해주세요.');
      stdout.writeln('  melos bootstrap');
      stdout.writeln('  melos run build:all');
    }
    return 0;
  }

  String _diTemplate(String projectName) => '''
import 'package:$projectName/di.config.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:data/di.dart' as data;
import 'package:domain/di.dart' as domain;
import 'package:presentation/di.dart' as presentation;

final di = GetIt.instance;

@InjectableInit()
GetIt configureDependencies() {
  data.configureDependencies(getIt: di);
  domain.configureDependencies(getIt: di);
  presentation.configureDependencies(getIt: di);

  return di.init();
}
''';

  String _mainTemplate(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di.dart';

void main() {
  configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Flutter Clean Architecture'),
          ),
        ),
      ),
    );
  }
}
''';
}
