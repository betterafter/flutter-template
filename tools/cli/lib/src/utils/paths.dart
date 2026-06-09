import 'dart:io';

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

String cliPackageRoot() {
  final script = Platform.script.toFilePath();
  return p.normalize(p.join(p.dirname(script), '..'));
}

String templateRoot() => p.join(cliPackageRoot(), 'templates');
