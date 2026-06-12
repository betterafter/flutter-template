import 'dart:io';

import 'package:args/command_runner.dart';

import '../utils/paths.dart';
import '../utils/process_runner.dart';

class BootstrapCommand extends Command<int> {
  @override
  String get name => 'bootstrap';

  @override
  String get description => '멀티 패키지 의존성 설치 (melos bootstrap 대체)';

  @override
  Future<int> run() async {
    final project = ProjectPaths.fromCwd();
    if (!project.hasCleanArchStructure) {
      stderr.writeln('Clean Architecture 구조가 없습니다.');
      stderr.writeln('먼저 `flutter_clean_arch init`을 실행해주세요.');
      return 1;
    }

    stdout.writeln('의존성을 설치합니다...\n');

    final runner = ProcessRunner();
    await runner.activateGlobal('melos');
    await runner.runMelos(['bootstrap'], workingDirectory: project.root);

    stdout.writeln('\n완료!');
    return 0;
  }
}
