import 'package:data/core/network/remote_failure.dart';
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(_mapToRemoteFailure(err));
  }

  DioException _mapToRemoteFailure(DioException err) {
    final statusCode = err.response?.statusCode;
    final message = _resolveMessage(err);

    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: RemoteFailure(
        message: message,
        statusCode: statusCode,
        cause: err,
      ),
      message: message,
    );
  }

  String _resolveMessage(DioException err) {
    final responseData = err.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ?? responseData['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '요청 시간이 초과되었습니다.';
      case DioExceptionType.connectionError:
        return '네트워크 연결을 확인해주세요.';
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다.';
      case DioExceptionType.badResponse:
        return '서버 오류가 발생했습니다. (${err.response?.statusCode})';
      case DioExceptionType.badCertificate:
        return '인증서 오류가 발생했습니다.';
      case DioExceptionType.unknown:
        return err.message ?? '알 수 없는 오류가 발생했습니다.';
    }
  }
}
