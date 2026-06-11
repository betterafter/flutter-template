enum DataStatus {
  initial,
  loading,
  success,
  error,
}

class DataState<T> {
  const DataState._({
    required this.status,
    this.data,
    this.error,
    this.message,
  });

  const DataState.initial() : this._(status: DataStatus.initial);

  const DataState.loading({T? data})
      : this._(status: DataStatus.loading, data: data);

  const DataState.success(T data)
      : this._(status: DataStatus.success, data: data);

  const DataState.error(
    Object error, {
    String? message,
    T? data,
  }) : this._(
          status: DataStatus.error,
          error: error,
          message: message,
          data: data,
        );

  final DataStatus status;
  final T? data;
  final Object? error;
  final String? message;

  bool get isInitial => status == DataStatus.initial;
  bool get isLoading => status == DataStatus.loading;
  bool get isSuccess => status == DataStatus.success;
  bool get isError => status == DataStatus.error;
  bool get hasData => data != null;

  DataState<T> copyWith({
    DataStatus? status,
    T? data,
    Object? error,
    String? message,
    bool clearData = false,
    bool clearError = false,
  }) {
    return DataState._(
      status: status ?? this.status,
      data: clearData ? null : (data ?? this.data),
      error: clearError ? null : (error ?? this.error),
      message: message ?? this.message,
    );
  }

  DataState<T> toLoading({bool keepData = true}) {
    return DataState.loading(data: keepData ? data : null);
  }

  DataState<R> map<R>(R Function(T data) transform) {
    final value = data;
    if (!isSuccess || value == null) {
      return DataState<R>._(
        status: status,
        error: error,
        message: message,
      );
    }

    return DataState.success(transform(value));
  }

  R when<R>({
    required R Function() initial,
    required R Function(T? data) loading,
    required R Function(T data) success,
    required R Function(Object error, String? message, T? data) error,
  }) {
    switch (status) {
      case DataStatus.initial:
        return initial();
      case DataStatus.loading:
        return loading(data);
      case DataStatus.success:
        return success(data as T);
      case DataStatus.error:
        return error(this.error!, message, data);
    }
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function(T? data)? loading,
    R Function(T data)? success,
    R Function(Object error, String? message, T? data)? error,
    required R Function() orElse,
  }) {
    switch (status) {
      case DataStatus.initial:
        return initial?.call() ?? orElse();
      case DataStatus.loading:
        return loading?.call(data) ?? orElse();
      case DataStatus.success:
        return success?.call(data as T) ?? orElse();
      case DataStatus.error:
        return error?.call(this.error!, message, data) ?? orElse();
    }
  }

  static Future<DataState<T>> guard<T>(
    Future<T> Function() call, {
    String Function(Object error)? onError,
  }) async {
    try {
      final result = await call();
      return DataState.success(result);
    } catch (e) {
      return DataState.error(
        e,
        message: onError?.call(e) ?? e.toString(),
      );
    }
  }
}
