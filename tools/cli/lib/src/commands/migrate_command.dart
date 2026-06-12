import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../utils/file_writer.dart';
import '../utils/paths.dart';
import '../utils/process_runner.dart';
import '../utils/project_prerequisites.dart';

class MigrateCommand extends Command<int> {
  MigrateCommand() {
    argParser.addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help: '코어 파일·melos.yaml·lib/di.dart·tool/fca를 최신 템플릿으로 덮어씁니다.',
    );
    argParser.addFlag(
      'skip-build',
      negatable: false,
      help: 'pub get 및 build_runner를 실행하지 않습니다.',
    );
    argParser.addFlag(
      'skip-pub-get',
      negatable: false,
      help: 'pub get만 생략합니다.',
    );
  }

  @override
  String get name => 'migrate';

  @override
  String get description =>
      '누락된 필수 파일·의존성·설정을 최신 템플릿 기준으로 보완합니다.';

  @override
  Future<int> run() async {
    final project = ProjectPaths.fromCwd();
    if (!project.hasCleanArchStructure) {
      stderr.writeln('Clean Architecture 구조가 없습니다.');
      stderr.writeln('먼저 `flutter_clean_arch init`을 실행해주세요.');
      return 1;
    }

    final force = argResults!['force'] as bool;
    final skipBuild = argResults!['skip-build'] as bool;
    final skipPubGet = argResults!['skip-pub-get'] as bool;

    stdout.writeln('프로젝트 마이그레이션을 시작합니다...\n');

    final result =
        await ProjectPrerequisites(FileWriter()).ensure(project, force: force);
    printPrerequisitesResult(result);
    stdout.writeln('');

    if (!result.hasChanges) {
      stdout.writeln('추가 작업이 필요하지 않습니다.');
      return 0;
    }

    final runner = ProcessRunner();

    if (!skipBuild && !skipPubGet) {
      stdout.writeln('의존성을 설치합니다...');
      await runner.activateGlobal('melos');
      await runner.runMelos(['bootstrap'], workingDirectory: project.root);
      stdout.writeln('');
    }

    if (!skipBuild) {
      stdout.writeln('코드 생성을 실행합니다...');
      final packagesDir = project.packagesDir;
      await runner.runBuildRunner(p.join(packagesDir, 'design'));
      await runner.runBuildRunner(p.join(packagesDir, 'domain'));
      await runner.runBuildRunner(p.join(packagesDir, 'data'));
      await runner.runBuildRunner(p.join(packagesDir, 'presentation'));
      await runner.runBuildRunner(project.root);
      stdout.writeln('');
    }

    stdout.writeln('마이그레이션 완료!');
    stdout.writeln('');
    stdout.writeln('다음 단계:');
    stdout.writeln('  1. 기존 feature의 Repository / Usecase를 DataState + remote() 패턴으로 수정');
    stdout.writeln('  2. feature별 Retrofit API 파일 추가 (참고: packages/data/lib/data/payment/api/)');
    stdout.writeln('  3. 파일 수정 후 코드 재생성: ${_fcaHint('build')}');

    return 0;
  }

  String _fcaHint(String args) {
    if (Platform.isWindows) {
      return 'tool\\fca $args';
    }
    return 'tool/fca $args';
  }
}
