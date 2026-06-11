class RemoteFailure implements Exception {
  const RemoteFailure({
    required this.message,
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  static String messageOf(Object error) {
    if (error is RemoteFailure) {
      return error.message;
    }

    return error.toString();
  }

  @override
  String toString() => 'RemoteFailure($statusCode): $message';
}
