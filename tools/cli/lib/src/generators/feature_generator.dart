import '../utils/name_converter.dart';

class FeatureGenerator {
  FeatureGenerator(this.feature, {required this.methods});

  final FeatureName feature;
  final List<String> methods;

  String get _c => feature.className;
  String get _f => feature.fileName;
  String get _v => feature.camelCase;

  Map<String, String> get variables => {
        'feature': _f,
        'className': _c,
        'camelCase': _v,
      };

  String render(String template) {
    var result = template;
    for (final entry in variables.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }
    return result;
  }

  String entity() => render('''
class {{className}}Entity {
  const {{className}}Entity({
    required this.id,
  });

  final String id;
}
''');

  String repository() => render('''
import 'package:domain/domain/{{feature}}/entity/{{feature}}.entity.dart';

abstract class {{className}}Repository {
${_repositoryMethods()}
}
''');

  String usecase() => render('''
import 'package:domain/domain/{{feature}}/entity/{{feature}}.entity.dart';
import 'package:domain/domain/{{feature}}/repository/{{feature}}.repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class {{className}}Usecase {
  {{className}}Usecase({required this.{{camelCase}}Repository});

  final {{className}}Repository {{camelCase}}Repository;

${_usecaseMethods()}
}
''');

  String model() => render('''
import 'package:domain/domain/{{feature}}/entity/{{feature}}.entity.dart';

class {{className}}Model {
  const {{className}}Model({
    required this.id,
  });

  final String id;

  {{className}}Entity toEntity() => {{className}}Entity(id: id);

  factory {{className}}Model.fromJson(Map<String, dynamic> json) {
    return {{className}}Model(
      id: json['id'] as String,
    );
  }
}
''');

  String remoteDatasource() => render('''
import 'package:data/data/{{feature}}/model/{{feature}}.model.dart';
import 'package:injectable/injectable.dart';

@injectable
class {{className}}RemoteDatasource {
  {{className}}RemoteDatasource();

${_remoteDatasourceMethods()}
}
''');

  String localDatasource() => render('''
import 'package:data/data/{{feature}}/model/{{feature}}.model.dart';
import 'package:injectable/injectable.dart';

@injectable
class {{className}}LocalDatasource {
  {{className}}LocalDatasource();

${_localDatasourceMethods()}
}
''');

  String repositoryImpl({required bool withLocal}) => render('''
import 'package:data/data/{{feature}}/datasource/{{feature}}.remote.datasource.dart';
${withLocal ? "import 'package:data/data/{{feature}}/datasource/{{feature}}.local.datasource.dart';" : ''}
import 'package:domain/domain/{{feature}}/entity/{{feature}}.entity.dart';
import 'package:domain/domain/{{feature}}/repository/{{feature}}.repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: {{className}}Repository)
class {{className}}RepositoryImpl implements {{className}}Repository {
  {{className}}RepositoryImpl(
    this._remoteDatasource,${withLocal ? '\n    this._localDatasource,' : ''}
  );

  final {{className}}RemoteDatasource _remoteDatasource;
${withLocal ? '  final {{className}}LocalDatasource _localDatasource;\n' : ''}
${_repositoryImplMethods()}
}
''');

  String provider() => render('''
import 'package:domain/domain/{{feature}}/usecase/{{feature}}.usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

final {{camelCase}}UsecaseProvider = Provider<{{className}}Usecase>(
  (ref) => GetIt.I<{{className}}Usecase>(),
);
''');

  String page() => render('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class {{className}}Page extends ConsumerWidget {
  const {{className}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('{{className}}')),
      body: const Center(
        child: Text('{{className}} 화면'),
      ),
    );
  }
}
''');

  String _repositoryMethods() {
    return methods.map((method) {
      return '  Future<List<{{className}}Entity>> $method();';
    }).join('\n');
  }

  String _usecaseMethods() {
    return methods.map((method) {
      return '''
  Future<List<{{className}}Entity>> $method() {
    return {{camelCase}}Repository.$method();
  }''';
    }).join('\n\n');
  }

  String _remoteDatasourceMethods() {
    return methods.map((method) {
      return '''
  Future<List<{{className}}Model>> $method() async {
    // TODO: API 호출 구현
    return [];
  }''';
    }).join('\n');
  }

  String _localDatasourceMethods() {
    return methods.map((method) {
      return '''
  Future<List<{{className}}Model>> $method() async {
    // TODO: 로컬 저장소 구현
    return [];
  }''';
    }).join('\n');
  }

  String _repositoryImplMethods() {
    return methods.map((method) {
      return '''
  @override
  Future<List<{{className}}Entity>> $method() async {
    final models = await _remoteDatasource.$method();
    return models.map((model) => model.toEntity()).toList();
  }''';
    }).join('\n\n');
  }
}
