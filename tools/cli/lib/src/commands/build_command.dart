import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../utils/paths.dart';
import '../utils/process_runner.dart';

class BuildCommand extends Command<int> {
  BuildCommand() {
    argParser.addOption(
      'scope',
      abbr: 's',
      help: 'all | domain | data | presentation | design | di',
      defaultsTo: 'all',
    );
    argParser.addFlag(
      'clean',
      negatable: false,
      help: 'build_runner 캐시(.dart_tool/build) 삭제 후 빌드',
    );
    argParser.addFlag(
      'force-jit',
      negatable: false,
      help: '처음부터 --force-jit 사용 (Windows AOT 오류 시)',
    );
  }

  @override
  String get name => 'build';

  @override
  String get description =>
      'build_runner 코드 생성. Windows AOT 실패 시 자동 --force-jit 재시도';

  @override
  Future<int> run() async {
    final project = ProjectPaths.fromCwd();
    if (!project.hasCleanArchStructure) {
      stderr.writeln('Clean Architecture 구조가 없습니다.');
      stderr.writeln('먼저 `flutter_clean_arch init`을 실행해주세요.');
      return 1;
    }

    final scope = argResults!['scope'] as String;
    final clean = argResults!['clean'] as bool;
    final forceJit = argResults!['force-jit'] as bool;
    final runner = ProcessRunner();
    final packagesDir = project.packagesDir;

    final options = [
      if (clean) 'clean',
      if (forceJit) 'force-jit',
    ].join(', ');
    stdout.writeln(
      '코드 생성을 실행합니다 (scope: $scope${options.isEmpty ? '' : ', $options'})...\n',
    );

    try {
      switch (scope) {
        case 'all':
          await _build(runner, p.join(packagesDir, 'design'), clean: clean, forceJit: forceJit);
          await _build(runner, p.join(packagesDir, 'domain'), clean: clean, forceJit: forceJit);
          await _build(runner, p.join(packagesDir, 'data'), clean: clean, forceJit: forceJit);
          await _build(runner, p.join(packagesDir, 'presentation'), clean: clean, forceJit: forceJit);
          await _build(runner, project.root, clean: clean, forceJit: forceJit);
        case 'domain':
          await _build(runner, p.join(packagesDir, 'domain'), clean: clean, forceJit: forceJit);
        case 'data':
          await _build(runner, p.join(packagesDir, 'data'), clean: clean, forceJit: forceJit);
        case 'presentation':
          await _build(runner, p.join(packagesDir, 'presentation'), clean: clean, forceJit: forceJit);
        case 'design':
          await _build(runner, p.join(packagesDir, 'design'), clean: clean, forceJit: forceJit);
        case 'di':
          await _build(runner, project.root, clean: clean, forceJit: forceJit);
        default:
          stderr.writeln('알 수 없는 scope: $scope');
          stderr.writeln('사용 가능: all, domain, data, presentation, design, di');
          return 1;
      }
    } on StateError catch (error) {
      stderr.writeln('\n코드 생성에 실패했습니다.');
      stderr.writeln(error.message);
      _printBuildFailureHints();
      return 1;
    }

    stdout.writeln('\n완료!');
    return 0;
  }

  Future<void> _build(
    ProcessRunner runner,
    String packagePath, {
    required bool clean,
    required bool forceJit,
  }) async {
    await runner.runBuildRunner(
      packagePath,
      clean: clean,
      forceJit: forceJit,
    );
  }

  void _printBuildFailureHints() {
    stderr.writeln('\n확인 사항:');
    stderr.writeln('  - tool/fca bootstrap 또는 migrate를 먼저 실행했는지');
    stderr.writeln('  - tool/fca build --clean 으로 캐시 삭제 후 재시도');
    if (Platform.isWindows) {
      stderr.writeln('  - tool/fca build --force-jit (AOT 오류 시)');
      stderr.writeln('  - 수동: flutter pub run build_runner build --force-jit');
      stderr.writeln('  - OneDrive·바탕 화면 대신 C:\\dev\\my_app 등 로컬 ASCII 경로');
      stderr.writeln('  - IDE 종료, Windows Defender 제어된 폴더 액세스 확인');
    }
  }
}
