import 'dart:io';

import 'package:path/path.dart' as p;

class FileWriter {
  Future<void> writeFile({
    required String path,
    required String content,
    bool force = false,
  }) async {
    final file = File(path);
    if (file.existsSync() && !force) {
      throw StateError('이미 파일이 존재합니다: $path');
    }

    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<bool> copyFileIfAbsent({
    required String source,
    required String destination,
  }) async {
    if (File(destination).existsSync()) {
      return false;
    }

    await copyFile(source: source, destination: destination, force: true);
    return true;
  }

  Future<void> copyFile({
    required String source,
    required String destination,
    bool force = false,
  }) async {
    final sourceFile = File(source);
    if (!sourceFile.existsSync()) {
      throw StateError('템플릿 파일을 찾을 수 없습니다: $source');
    }

    final targetFile = File(destination);
    if (targetFile.existsSync() && !force) {
      throw StateError('이미 파일이 존재합니다: $destination');
    }

    await targetFile.parent.create(recursive: true);
    await sourceFile.copy(destination);
  }

  Future<void> copyDirectory({
    required String source,
    required String destination,
    bool force = false,
  }) async {
    final sourceDir = Directory(source);
    if (!sourceDir.existsSync()) {
      throw StateError('템플릿 디렉터리를 찾을 수 없습니다: $source');
    }

    await for (final entity in sourceDir.list(recursive: true)) {
      final relative = p.relative(entity.path, from: source);
      final targetPath = p.join(destination, relative);

      if (entity is Directory) {
        await Directory(targetPath).create(recursive: true);
        continue;
      }

      if (entity is File) {
        final targetFile = File(targetPath);
        if (targetFile.existsSync() && !force) {
          throw StateError('이미 파일이 존재합니다: $targetPath');
        }
        await targetFile.parent.create(recursive: true);
        await entity.copy(targetPath);
      }
    }
  }
}
