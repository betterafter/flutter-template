import 'package:data/core/network/remote_failure.dart';
import 'package:dio/dio.dart';
import 'package:domain/core/data_state.dart';

Future<DataState<T>> remote<T>(Future<T> Function() call) {
  return DataState.guard(call, onError: _resolveMessage);
}

String _resolveMessage(Object error) {
  if (error is DioException) {
    final wrapped = error.error;
    if (wrapped is RemoteFailure) {
      return wrapped.message;
    }
    return error.message ?? error.toString();
  }

  return RemoteFailure.messageOf(error);
}
