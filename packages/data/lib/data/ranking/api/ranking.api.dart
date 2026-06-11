import 'package:data/data/ranking/dto/ranking.dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'ranking.api.g.dart';

@RestApi()
abstract class RankingApi {
  factory RankingApi(Dio dio, {String baseUrl}) = _RankingApi;

  @GET('/api/ranking')
  Future<List<RankingDto>> getRankings();
}
