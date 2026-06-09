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

  String dto() => render('''
class {{className}}Dto {
  const {{className}}Dto({
    required this.id,
  });

  final String id;

  factory {{className}}Dto.fromJson(Map<String, dynamic> json) {
    return {{className}}Dto(
      id: json['id'] as String,
    );
  }
}
''');

  String dtoParser() => render('''
import 'package:data/data/{{feature}}/dto/{{feature}}.dto.dart';

List<{{className}}Dto> parse{{className}}DtoList(List<dynamic> jsonList) {
  return jsonList
      .map((json) => {{className}}Dto.fromJson(json as Map<String, dynamic>))
      .toList();
}
''');

  String mapper() => render('''
import 'package:data/data/{{feature}}/dto/{{feature}}.dto.dart';
import 'package:domain/domain/{{feature}}/entity/{{feature}}.entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class {{className}}Mapper {
  {{className}}Entity toEntity({{className}}Dto dto) {
    return {{className}}Entity(id: dto.id);
  }

  List<{{className}}Entity> toEntityList(List<{{className}}Dto> dtos) {
    return dtos.map(toEntity).toList();
  }
}
''');

  String remoteDatasource() => render('''
import 'package:data/data/{{feature}}/dto/{{feature}}.dto.dart';
import 'package:data/data/{{feature}}/dto/{{feature}}.dto.parser.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class {{className}}RemoteDatasource {
  {{className}}RemoteDatasource();

${_remoteDatasourceMethods()}
}
''');

  String localDatasource() => render('''
import 'package:data/data/{{feature}}/dto/{{feature}}.dto.dart';
import 'package:data/data/{{feature}}/dto/{{feature}}.dto.parser.dart';
import 'package:flutter/foundation.dart';
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
import 'package:data/data/{{feature}}/mapper/{{feature}}.mapper.dart';
import 'package:domain/domain/{{feature}}/entity/{{feature}}.entity.dart';
import 'package:domain/domain/{{feature}}/repository/{{feature}}.repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: {{className}}Repository)
class {{className}}RepositoryImpl implements {{className}}Repository {
  {{className}}RepositoryImpl(
    this._remoteDatasource,
    this._mapper,${withLocal ? '\n    this._localDatasource,' : ''}
  );

  final {{className}}RemoteDatasource _remoteDatasource;
  final {{className}}Mapper _mapper;
${withLocal ? '  final {{className}}LocalDatasource _localDatasource;\n' : ''}
${_repositoryImplMethods(withLocal: withLocal)}
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
      final fetchMethod = '_fetch${_methodPascalCase(method)}Json';
      final parser = 'parse{{className}}DtoList';
      return '''
  Future<List<{{className}}Dto>> $method() async {
    final jsonList = await $fetchMethod();
    return compute($parser, jsonList);
  }

  Future<List<dynamic>> $fetchMethod() async {
    // TODO: HTTP 클라이언트로 API 호출 후 response.body를 jsonDecode
    return [];
  }''';
    }).join('\n');
  }

  String _localDatasourceMethods() {
    return methods.map((method) {
      final fetchMethod = '_fetch${_methodPascalCase(method)}Json';
      final parser = 'parse{{className}}DtoList';
      return '''
  Future<List<{{className}}Dto>> $method() async {
    final jsonList = await $fetchMethod();
    return compute($parser, jsonList);
  }

  Future<List<dynamic>> $fetchMethod() async {
    // TODO: 로컬 저장소에서 JSON 목록 로드
    return [];
  }''';
    }).join('\n');
  }

  String _repositoryImplMethods({required bool withLocal}) {
    return methods.map((method) {
      if (withLocal) {
        return '''
  @override
  Future<List<{{className}}Entity>> $method() async {
    final dtos = await _remoteDatasource.$method();
    return _mapper.toEntityList(dtos);
  }''';
      }
      return '''
  @override
  Future<List<{{className}}Entity>> $method() async {
    final dtos = await _remoteDatasource.$method();
    return _mapper.toEntityList(dtos);
  }''';
    }).join('\n\n');
  }

  String _methodPascalCase(String method) {
    if (method.isEmpty) return '';
    return method[0].toUpperCase() + method.substring(1);
  }
}
