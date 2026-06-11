import 'package:data/core/network/interceptors/error_interceptor.dart';
import 'package:data/core/network/interceptors/logging_interceptor.dart';
import 'package:data/data/ranking/datasource/ranking.remote.datasource.dart';
import 'package:data/data/ranking/mapper/ranking.mapper.dart';
import 'package:data/data/ranking/repository/ranking.repository.dart';
import 'package:domain/core/data_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RankingRepositoryImpl repository;

  setUp(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://keykat.kr',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    dio.interceptors.addAll([
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    repository = RankingRepositoryImpl(
      RankingRemoteDatasource(dio),
      RankingMapper(),
    );
  });

  test('getRankings returns DataStateSuccess with entities', () async {
    final result = await repository.getRankings();

    expect(result, isA<DataStateSuccess>());
    final rankings = (result as DataStateSuccess).data;
    expect(rankings, isNotEmpty);
    expect(rankings.first.nickname, isA<String>());
    expect(rankings.first.rank, isPositive);
  });
}
