import 'package:domain/core/data_state.dart';
import 'package:domain/domain/ranking/entity/ranking.entity.dart';
import 'package:domain/domain/ranking/repository/ranking.repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RankingUsecase {
  RankingUsecase({required this.rankingRepository});

  final RankingRepository rankingRepository;

  Future<DataState<List<RankingEntity>>> getRankings() {
    return rankingRepository.getRankings();
  }
}
