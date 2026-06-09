class FeatureName {
  FeatureName._(this.raw);

  factory FeatureName.parse(String input) {
    final normalized = input.trim().toLowerCase().replaceAll('-', '_');
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(normalized)) {
      throw FormatException(
        'feature 이름은 snake_case 영문으로 입력해주세요. (예: payment, payment_history)',
      );
    }
    return FeatureName._(normalized);
  }

  final String raw;

  String get className => _snakeToPascalCase(raw);

  String get camelCase => _snakeToCamelCase(raw);

  String get fileName => raw;

  List<String> defaultMethods() => ['get${className}s'];

  static String methodToCamelCase(String method) {
    final normalized = method.trim().replaceAll('-', '_');
    if (normalized.contains('_')) {
      return _snakeToCamelCase(normalized);
    }
    if (normalized.isEmpty) {
      throw const FormatException('메서드 이름이 비어 있습니다.');
    }
    return normalized[0].toLowerCase() + normalized.substring(1);
  }

  static String _snakeToPascalCase(String input) {
    return input
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join();
  }

  static String _snakeToCamelCase(String input) {
    final pascal = _snakeToPascalCase(input);
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
