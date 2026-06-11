import 'package:data/data/ranking/dto/ranking.dto.dart';

List<RankingDto> parseRankingDtoList(List<dynamic> jsonList) {
  return jsonList
      .map((json) => RankingDto.fromJson(json as Map<String, dynamic>))
      .toList();
}
