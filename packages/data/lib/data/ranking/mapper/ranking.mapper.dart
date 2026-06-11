import 'package:data/data/ranking/dto/ranking.dto.dart';
import 'package:domain/domain/ranking/entity/ranking.entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class RankingMapper {
  RankingEntity toEntity(RankingDto dto) {
    return RankingEntity(
      id: dto.id,
      nickname: dto.nickname,
      rank: dto.rank,
      region: dto.region,
      winRate: dto.winRate,
      winCount: dto.winCount,
      profileImageUrl: dto.profileImageUrl,
    );
  }

  List<RankingEntity> toEntityList(List<RankingDto> dtos) {
    return dtos.map(toEntity).toList();
  }
}
