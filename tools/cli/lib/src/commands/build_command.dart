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
  }

  @override
  String get name => 'build';

  @override
  String get description => 'build_runner 코드 생성 (melos build:* 대체)';

  @override
  Future<int> run() async {
    final project = ProjectPaths.fromCwd();
    if (!project.hasCleanArchStructure) {
      stderr.writeln('Clean Architecture 구조가 없습니다.');
      stderr.writeln('먼저 `flutter_clean_arch init`을 실행해주세요.');
      return 1;
    }

    final scope = argResults!['scope'] as String;
    final runner = ProcessRunner();
    final packagesDir = project.packagesDir;

    stdout.writeln('코드 생성을 실행합니다 (scope: $scope)...\n');

    switch (scope) {
      case 'all':
        await runner.runBuildRunner(p.join(packagesDir, 'design'));
        await runner.runBuildRunner(p.join(packagesDir, 'domain'));
        await runner.runBuildRunner(p.join(packagesDir, 'data'));
        await runner.runBuildRunner(p.join(packagesDir, 'presentation'));
        await runner.runBuildRunner(project.root);
      case 'domain':
        await runner.runBuildRunner(p.join(packagesDir, 'domain'));
      case 'data':
        await runner.runBuildRunner(p.join(packagesDir, 'data'));
      case 'presentation':
        await runner.runBuildRunner(p.join(packagesDir, 'presentation'));
      case 'design':
        await runner.runBuildRunner(p.join(packagesDir, 'design'));
      case 'di':
        await runner.runBuildRunner(project.root);
      default:
        stderr.writeln('알 수 없는 scope: $scope');
        stderr.writeln('사용 가능: all, domain, data, presentation, design, di');
        return 1;
    }

    stdout.writeln('\n완료!');
    return 0;
  }
}
