import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

class ProjectPaths {
  ProjectPaths(this.root);

  final String root;

  factory ProjectPaths.fromCwd() => ProjectPaths(Directory.current.path);

  String get pubspec => p.join(root, 'pubspec.yaml');
  String get melos => p.join(root, 'melos.yaml');
  String get packagesDir => p.join(root, 'packages');

  String domainPackage(String relative) =>
      p.join(packagesDir, 'domain', relative);

  String dataPackage(String relative) => p.join(packagesDir, 'data', relative);

  String presentationPackage(String relative) =>
      p.join(packagesDir, 'presentation', relative);

  bool get isFlutterProject => File(pubspec).existsSync();

  bool get hasCleanArchStructure =>
      Directory(p.join(packagesDir, 'domain')).existsSync() &&
      Directory(p.join(packagesDir, 'data')).existsSync() &&
      Directory(p.join(packagesDir, 'presentation')).existsSync() &&
      Directory(p.join(packagesDir, 'design')).existsSync();
}

/// pub.dev global install(snapshot), dart run, 로컬 개발 모두에서 동작합니다.
Future<String> templateRoot() async {
  final markerUri = await Isolate.resolvePackageUri(
    Uri.parse('package:flutter_clean_arch_scaffold/src/_package_marker.dart'),
  );

  if (markerUri == null) {
    throw StateError(_templateErrorMessage);
  }

  final packageRoot = p.normalize(
    p.join(p.dirname(markerUri.toFilePath()), '..', '..'),
  );
  final templatesPath = p.join(packageRoot, 'templates');

  if (!Directory(templatesPath).existsSync()) {
    throw StateError(_templateErrorMessage);
  }

  return templatesPath;
}

const _templateErrorMessage =
    'CLI templates 디렉터리를 찾을 수 없습니다.\n'
    'flutter_clean_arch_scaffold 패키지가 올바르게 설치되었는지 확인해주세요.';
