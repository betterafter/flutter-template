import 'package:flutter_clean_arch_scaffold/src/cli_runner.dart';

Future<void> main(List<String> arguments) async {
  await CliRunner().execute(arguments);
}
