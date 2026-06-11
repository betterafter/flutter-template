class RankingEntity {
  const RankingEntity({
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
}
