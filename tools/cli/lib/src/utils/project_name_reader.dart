import 'dart:io';

import 'package:yaml/yaml.dart';

class ProjectNameReader {
  static Future<String> read(String pubspecPath) async {
    final file = File(pubspecPath);
    final doc = loadYaml(await file.readAsString());
    final name = doc['name'];
    if (name is! String || name.isEmpty) {
      throw StateError('pubspec.yaml에서 프로젝트 이름을 읽을 수 없습니다.');
    }
    return name;
  }
}
