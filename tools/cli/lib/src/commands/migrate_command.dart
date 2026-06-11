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
      help: '원격 데이터 레이어 코어 파일을 최신 템플릿으로 덮어씁니다.',
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
      '0.1.x 프로젝트에 DataState·네트워크 코어·data pubspec 의존성을 추가합니다.';

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

    stdout.writeln('원격 데이터 레이어 마이그레이션을 시작합니다...\n');

    final result =
        await ProjectPrerequisites(FileWriter()).ensure(project, force: force);
    printPrerequisitesResult(result);
    stdout.writeln('');

    if (!result.hasChanges) {
      stdout.writeln('추가 작업이 필요하지 않습니다.');
      return 0;
    }

    if (!skipBuild && !skipPubGet) {
      stdout.writeln('의존성을 설치합니다...');
      final runner = ProcessRunner();
      final dataPackage = p.join(project.packagesDir, 'data');
      await runner.run('flutter', ['pub', 'get'], workingDirectory: dataPackage);
      stdout.writeln('');
    }

    if (!skipBuild) {
      stdout.writeln('build_runner를 실행합니다...');
      final runner = ProcessRunner();
      await runner.runBuildRunner(p.join(project.packagesDir, 'domain'));
      await runner.runBuildRunner(p.join(project.packagesDir, 'data'));
      stdout.writeln('');
    }

    stdout.writeln('마이그레이션 완료!');
    stdout.writeln('');
    stdout.writeln('다음 단계:');
    stdout.writeln('  1. 기존 feature의 Repository / Usecase를 DataState + remote() 패턴으로 수정');
    stdout.writeln('  2. feature별 Retrofit API 파일 추가 (참고: packages/data/lib/data/payment/api/)');
    stdout.writeln('  3. melos run build:data 로 코드 재생성');

    return 0;
  }
}
