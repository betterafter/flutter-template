import 'package:data/data/ranking/api/ranking.api.dart';
import 'package:data/data/ranking/dto/ranking.dto.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class RankingRemoteDatasource {
  RankingRemoteDatasource(Dio dio) : _api = RankingApi(dio);

  final RankingApi _api;

  Future<List<RankingDto>> getRankings() => _api.getRankings();
}
