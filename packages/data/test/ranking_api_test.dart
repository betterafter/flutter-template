import 'package:data/core/network/interceptors/error_interceptor.dart';
import 'package:data/data/ranking/api/ranking.api.dart';
import 'package:data/data/ranking/dto/ranking.dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  late RankingApi rankingApi;

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://keykat.kr',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    dio.interceptors.add(ErrorInterceptor());
    rankingApi = RankingApi(dio);
  });

  test('GET /api/ranking returns ranking list', () async {
    final response = await rankingApi.getRankings();

    expect(response, isA<List<RankingDto>>());
    expect(response, isNotEmpty);
    expect(response.first.nickname, isA<String>());
    expect(response.first.rank, isPositive);
    expect(response.first.region, isA<String>());
    expect(response.first.winRate, isA<double>());
    expect(response.first.winCount, isPositive);
    expect(response.first.profileImageUrl, isA<String>());
  });
}
