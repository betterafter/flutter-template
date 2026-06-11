import 'package:domain/core/data_state.dart';
import 'package:domain/domain/ranking/entity/ranking.entity.dart';

abstract class RankingRepository {
  Future<DataState<List<RankingEntity>>> getRankings();
}
