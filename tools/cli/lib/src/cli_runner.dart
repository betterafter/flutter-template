import 'dart:io';

import 'package:args/command_runner.dart';

import 'commands/add_feature_command.dart';
import 'commands/bootstrap_command.dart';
import 'commands/build_command.dart';
import 'commands/init_command.dart';
import 'commands/migrate_command.dart';

class CliRunner extends CommandRunner<int> {
  CliRunner()
      : super(
          'flutter_clean_arch',
          'Flutter Clean Architecture 프로젝트 스캐폴딩 CLI',
        ) {
    addCommand(InitCommand());
    addCommand(AddFeatureCommand());
    addCommand(BootstrapCommand());
    addCommand(BuildCommand());
    addCommand(MigrateCommand());
  }

  Future<void> execute(List<String> arguments) async {
    try {
      final exitCode = await run(arguments) ?? 0;
      if (exitCode != 0) {
        exit(exitCode);
      }
    } on UsageException catch (error) {
      stderr.writeln(error);
      stderr.writeln();
      stderr.writeln(usage);
      exit(64);
    }
  }
}
