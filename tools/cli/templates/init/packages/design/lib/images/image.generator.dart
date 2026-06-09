// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;

class ImageGenerator extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.generated.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final iconDir = Directory('assets');

    final iconsBuffer = StringBuffer();
    await _generateIconGenerated(iconDir, iconsBuffer);
    // ManittoIcons 파일 생성
    final iconOutputId = AssetId(
      buildStep.inputId.package,
      'lib/images/image.generated.dart',
    );
    await buildStep.writeAsString(
      iconOutputId,
      iconsBuffer.toString(),
    );

    return;
  }

  Future<void> _generateIconGenerated(
    Directory dir,
    StringBuffer iconsBuffer,
  ) async {
    iconsBuffer.writeln('// ignore_for_file: must_be_immutable');
    iconsBuffer.writeln();
    // ManittoIcons 클래스 생성
    iconsBuffer.writeln('part of \'image.dart\';');
    iconsBuffer.writeln();
    iconsBuffer.writeln('class FlutterImages extends FlutterImage {');
    iconsBuffer.writeln('''  FlutterImages(
      {super.key,
      super.svg,
      super.size,
      super.color,
      super.width,
      super.height,
      super.colorBlendMode});''');

    for (var entity in dir.listSync(recursive: true)) {
      if (entity is File &&
              (entity.path.toLowerCase().endsWith('.svg') ||
                  entity.path.toLowerCase().endsWith('.png')) ||
          entity.path.toLowerCase().endsWith('.jpg') ||
          entity.path.toLowerCase().endsWith('.jpeg') ||
          entity.path.toLowerCase().endsWith('.gif')) {
        final relativePath = path.relative(entity.path, from: 'assets');
        final parentDir = path.basename(path.dirname(entity.path));
        final fileName = path.basenameWithoutExtension(entity.path);
        final constName = _toConstName('${parentDir}_$fileName');

        // ManittoIcons에 팩토리 메서드 추가
        iconsBuffer.writeln();
        iconsBuffer.writeln('''  factory FlutterImages.$constName({
      double? size, 
      Color? color,
      double? width, 
      double? height, 
      BlendMode? colorBlendMode}) {''');
        iconsBuffer.writeln('    return FlutterImages(');
        iconsBuffer.writeln(
          '      svg: \'packages/design/assets/$relativePath\',',
        );
        iconsBuffer.writeln('      size: size,');
        iconsBuffer.writeln('      width: width,');
        iconsBuffer.writeln('      height: height,');
        iconsBuffer.writeln('      color: color,');
        iconsBuffer.writeln('      colorBlendMode: colorBlendMode,');
        iconsBuffer.writeln('    );');
        iconsBuffer.writeln('  }');
      }
    }

    iconsBuffer.writeln('}');
  }

  String _toConstName(String fileName) {
    final name =
        fileName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    return _snakeToCamelCase(name);
  }

  String _snakeToCamelCase(String input) {
    return input.split('_').asMap().entries.map((entry) {
      final word = entry.value;
      if (entry.key == 0) {
        return word.toLowerCase();
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join('');
  }
}

Builder imageGeneratorBuilder(BuilderOptions options) => ImageGenerator();
