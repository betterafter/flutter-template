import 'package:data/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:domain/core/data_state.dart';

Future<DataState<T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return DataStateSuccess(result);
  } on DioException catch (e) {
    final error = e.error;
    if (error is ApiException) {
      return DataStateError<T>(error, message: error.message);
    }
    return DataStateError<T>(e, message: e.message);
  } on ApiException catch (e) {
    return DataStateError<T>(e, message: e.message);
  } catch (e) {
    return DataStateError<T>(e, message: e.toString());
  }
}
