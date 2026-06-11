sealed class DataState<T> {
  const DataState();
}

final class DataStateInitial<T> extends DataState<T> {
  const DataStateInitial();
}

final class DataStateLoading<T> extends DataState<T> {
  const DataStateLoading();
}

final class DataStateSuccess<T> extends DataState<T> {
  const DataStateSuccess(this.data);

  final T data;
}

final class DataStateError<T> extends DataState<T> {
  const DataStateError(this.error, {this.message});

  final Object error;
  final String? message;
}

extension DataStateX<T> on DataState<T> {
  bool get isInitial => this is DataStateInitial<T>;
  bool get isLoading => this is DataStateLoading<T>;
  bool get isSuccess => this is DataStateSuccess<T>;
  bool get isError => this is DataStateError<T>;

  T? get dataOrNull =>
      this is DataStateSuccess<T> ? (this as DataStateSuccess<T>).data : null;
}
