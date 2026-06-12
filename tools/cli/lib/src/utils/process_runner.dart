import 'dart:io';

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

  Future<void> runBuildRunner(String packagePath) async {
    final hasFlutter = await _commandExists('flutter');
    final executable = hasFlutter ? 'flutter' : 'dart';
    final arguments = hasFlutter
        ? ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs']
        : ['run', 'build_runner', 'build', '--delete-conflicting-outputs'];

    await run(
      executable,
      arguments,
      workingDirectory: packagePath,
    );
  }

  Future<bool> _commandExists(String command) async {
    final lookup = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(lookup, [command], runInShell: true);
    return result.exitCode == 0;
  }
}
