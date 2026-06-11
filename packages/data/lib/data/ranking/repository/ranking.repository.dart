import 'package:data/core/network/remote.dart';
import 'package:data/data/ranking/datasource/ranking.remote.datasource.dart';
import 'package:data/data/ranking/mapper/ranking.mapper.dart';
import 'package:domain/core/data_state.dart';
import 'package:domain/domain/ranking/entity/ranking.entity.dart';
import 'package:domain/domain/ranking/repository/ranking.repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: RankingRepository)
class RankingRepositoryImpl implements RankingRepository {
  RankingRepositoryImpl(
    this._remoteDatasource,
    this._mapper,
  );

  final RankingRemoteDatasource _remoteDatasource;
  final RankingMapper _mapper;

  @override
  Future<DataState<List<RankingEntity>>> getRankings() {
    return remote(() async {
      final dtos = await _remoteDatasource.getRankings();
      return _mapper.toEntityList(dtos);
    });
  }
}
