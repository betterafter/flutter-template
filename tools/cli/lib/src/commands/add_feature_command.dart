import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../generators/feature_generator.dart';
import '../utils/file_writer.dart';
import '../utils/name_converter.dart';
import '../utils/paths.dart';
import '../utils/process_runner.dart';

class AddFeatureCommand extends Command<int> {
  AddFeatureCommand() {
    addSubcommand(_AddFeatureSubCommand());
  }

  @override
  String get name => 'add';

  @override
  String get description => 'feature 관련 파일을 생성합니다.';
}

class _AddFeatureSubCommand extends Command<int> {
  _AddFeatureSubCommand() {
    argParser.addFlag(
      'with-local',
      negatable: false,
      help: 'local datasource 파일을 함께 생성합니다.',
    );
    argParser.addFlag(
      'with-ui',
      negatable: false,
      help: 'presentation 레이어(provider, page)를 함께 생성합니다.',
    );
    argParser.addOption(
      'methods',
      help: '생성할 메서드 목록 (쉼표 구분). 예: getPayments,createPayment',
    );
    argParser.addFlag(
      'skip-build',
      negatable: false,
      help: '생성 후 build_runner를 실행하지 않습니다.',
    );
    argParser.addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help: '이미 존재하는 파일을 덮어씁니다.',
    );
  }

  @override
  String get name => 'feature';

  @override
  String get description => 'domain/data/presentation feature 구조를 생성합니다.';

  @override
  String get invocation =>
      '${super.invocation} <feature_name> [--with-local] [--with-ui] [--methods ...]';

  @override
  Future<int> run() async {
    final featureArg = argResults!.rest.isNotEmpty ? argResults!.rest.first : null;
    if (featureArg == null || featureArg.isEmpty) {
      stderr.writeln('feature 이름을 입력해주세요.');
      stderr.writeln('예: flutter_clean_arch add feature payment');
      return 1;
    }

    final project = ProjectPaths.fromCwd();
    if (!project.hasCleanArchStructure) {
      stderr.writeln('Clean Architecture 구조가 없습니다.');
      stderr.writeln('먼저 `flutter_clean_arch init`을 실행해주세요.');
      return 1;
    }

    final feature = FeatureName.parse(featureArg);
    final withLocal = argResults!['with-local'] as bool;
    final withUi = argResults!['with-ui'] as bool;
    final skipBuild = argResults!['skip-build'] as bool;
    final force = argResults!['force'] as bool;

    final methods = _parseMethods(
      argResults!['methods'] as String?,
      feature,
    );

    final generator = FeatureGenerator(feature, methods: methods);
    final writer = FileWriter();
    final createdFiles = <String>[];

    Future<void> write(String relativePath, String content) async {
      final fullPath = p.isAbsolute(relativePath)
          ? relativePath
          : p.join(project.root, relativePath);
      await writer.writeFile(path: fullPath, content: content, force: force);
      createdFiles.add(p.relative(fullPath, from: project.root));
    }

    stdout.writeln('feature "${feature.raw}" 생성 중...\n');

    await write(
      project.domainPackage('lib/domain/${feature.fileName}/entity/${feature.fileName}.entity.dart'),
      generator.entity(),
    );
    await write(
      project.domainPackage(
        'lib/domain/${feature.fileName}/repository/${feature.fileName}.repository.dart',
      ),
      generator.repository(),
    );
    await write(
      project.domainPackage(
        'lib/domain/${feature.fileName}/usecase/${feature.fileName}.usecase.dart',
      ),
      generator.usecase(),
    );

    await write(
      project.dataPackage('lib/data/${feature.fileName}/model/${feature.fileName}.model.dart'),
      generator.model(),
    );
    await write(
      project.dataPackage(
        'lib/data/${feature.fileName}/datasource/${feature.fileName}.remote.datasource.dart',
      ),
      generator.remoteDatasource(),
    );
    await write(
      project.dataPackage(
        'lib/data/${feature.fileName}/repository/${feature.fileName}.repository.dart',
      ),
      generator.repositoryImpl(withLocal: withLocal),
    );

    if (withLocal) {
      await write(
        project.dataPackage(
          'lib/data/${feature.fileName}/datasource/${feature.fileName}.local.datasource.dart',
        ),
        generator.localDatasource(),
      );
    }

    if (withUi) {
      await write(
        project.presentationPackage(
          'lib/${feature.fileName}/provider/${feature.fileName}.provider.dart',
        ),
        generator.provider(),
      );
      await write(
        project.presentationPackage(
          'lib/${feature.fileName}/page/${feature.fileName}.page.dart',
        ),
        generator.page(),
      );
    }

    for (final file in createdFiles) {
      stdout.writeln('✓ $file');
    }

    if (!skipBuild) {
      stdout.writeln('\nbuild_runner를 실행합니다...');
      final runner = ProcessRunner();
      await runner.runBuildRunner(p.join(project.packagesDir, 'domain'));
      await runner.runBuildRunner(p.join(project.packagesDir, 'data'));
      if (withUi) {
        await runner.runBuildRunner(p.join(project.packagesDir, 'presentation'));
      }
    }

    stdout.writeln('\n완료! 비즈니스 로직을 구현해주세요.');
    stdout.writeln('  domain: packages/domain/lib/domain/${feature.fileName}/');
    stdout.writeln('  data: packages/data/lib/data/${feature.fileName}/');
    if (withUi) {
      stdout.writeln(
        '  presentation: packages/presentation/lib/${feature.fileName}/',
      );
    }

    return 0;
  }

  List<String> _parseMethods(String? raw, FeatureName feature) {
    if (raw == null || raw.trim().isEmpty) {
      return feature.defaultMethods();
    }

    return raw
        .split(',')
        .map((method) => FeatureName.methodToCamelCase(method))
        .toList();
  }
}
