import 'dart:io';

import 'package:path/path.dart' as p;

class ProcessRunner {
  Future<bool> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool required = false,
  }) async {
    stdout.writeln('→ $executable ${arguments.join(' ')}');

    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final message =
          '명령 실행 실패 (exit $exitCode): $executable ${arguments.join(' ')}';
      if (required) {
        throw StateError(message);
      }
      stderr.writeln('⚠ $message');
      return false;
    }

    return true;
  }

  Future<void> activateGlobal(String package) async {
    await run(
      'dart',
      ['pub', 'global', 'activate', package],
      required: true,
    );
  }

  Future<bool> runGlobal(
    String package,
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool required = false,
  }) async {
    return run(
      'dart',
      ['pub', 'global', 'run', '$package:$executable', ...arguments],
      workingDirectory: workingDirectory,
      required: required,
    );
  }

  Future<void> runMelos(
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    await runGlobal(
      'melos',
      'melos',
      arguments,
      workingDirectory: workingDirectory,
      required: true,
    );
  }

  Future<void> runPubGet(String packagePath) async {
    final hasFlutter = await _commandExists('flutter');
    if (hasFlutter) {
      await run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: packagePath,
        required: true,
      );
      return;
    }

    await run(
      'dart',
      ['pub', 'get'],
      workingDirectory: packagePath,
      required: true,
    );
  }

  /// `flutter pub run build_runner build --delete-conflicting-outputs`
  /// flutter 없을 때만 `dart run` fallback. Windows AOT 실패 시 `--force-jit` 재시도.
  Future<void> runBuildRunner(
    String packagePath, {
    bool clean = false,
    bool forceJit = false,
  }) async {
    if (clean) {
      await clearBuildRunnerCache(packagePath);
    }

    await runPubGet(packagePath);

    final useFlutter = await _commandExists('flutter');

    if (forceJit) {
      await _runBuildRunner(
        packagePath,
        forceJit: true,
        useFlutter: useFlutter,
      );
      return;
    }

    final succeeded = await run(
      _buildRunnerExecutable(useFlutter),
      _buildRunnerArgs(forceJit: false, useFlutter: useFlutter),
      workingDirectory: packagePath,
    );

    if (succeeded) {
      return;
    }

    if (Platform.isWindows) {
      stdout.writeln(
        '→ AOT 빌드 실패, --force-jit으로 재시도 (${p.basename(packagePath)})...',
      );
      await clearBuildRunnerCache(packagePath);
      await _runBuildRunner(
        packagePath,
        forceJit: true,
        useFlutter: useFlutter,
      );
      return;
    }

    throw StateError(
      'build_runner build 실패: ${p.basename(packagePath)}',
    );
  }

  Future<void> _runBuildRunner(
    String packagePath, {
    required bool forceJit,
    required bool useFlutter,
  }) async {
    await run(
      _buildRunnerExecutable(useFlutter),
      _buildRunnerArgs(forceJit: forceJit, useFlutter: useFlutter),
      workingDirectory: packagePath,
      required: true,
    );
  }

  String _buildRunnerExecutable(bool useFlutter) =>
      useFlutter ? 'flutter' : 'dart';

  List<String> _buildRunnerArgs({
    required bool forceJit,
    required bool useFlutter,
  }) {
    return [
      if (useFlutter) ...['pub', 'run'] else 'run',
      'build_runner',
      'build',
      if (forceJit) '--force-jit',
      '--delete-conflicting-outputs',
    ];
  }

  List<String> _buildRunnerCleanArgs({required bool useFlutter}) {
    return [
      if (useFlutter) ...['pub', 'run'] else 'run',
      'build_runner',
      'clean',
    ];
  }

  Future<void> clearBuildRunnerCache(String packagePath) async {
    final buildDir = Directory(p.join(packagePath, '.dart_tool', 'build'));
    if (buildDir.existsSync()) {
      stdout.writeln('→ .dart_tool/build 삭제 (${p.basename(packagePath)})');
      await buildDir.delete(recursive: true);
    }

    final useFlutter = await _commandExists('flutter');
    await run(
      _buildRunnerExecutable(useFlutter),
      _buildRunnerCleanArgs(useFlutter: useFlutter),
      workingDirectory: packagePath,
    );
  }

  Future<bool> _commandExists(String command) async {
    if (Platform.isWindows) {
      final result = await Process.run(
        'where.exe',
        [command],
        runInShell: false,
      );
      return result.exitCode == 0 &&
          result.stdout.toString().trim().isNotEmpty;
    }

    final result = await Process.run('which', [command], runInShell: true);
    return result.exitCode == 0;
  }
}
