class RankingDto {
  const RankingDto({
    required this.id,
    required this.nickname,
    required this.rank,
    required this.region,
    required this.winRate,
    required this.winCount,
    required this.profileImageUrl,
  });

  final String id;
  final String nickname;
  final int rank;
  final String region;
  final double winRate;
  final int winCount;
  final String profileImageUrl;

  factory RankingDto.fromJson(Map<String, dynamic> json) {
    return RankingDto(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      rank: (json['rank'] as num).toInt(),
      region: json['region'] as String,
      winRate: (json['winRate'] as num).toDouble(),
      winCount: (json['winCount'] as num).toInt(),
      profileImageUrl: json['profileImageUrl'] as String,
    );
  }
}
