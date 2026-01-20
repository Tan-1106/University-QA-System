class DashboardStatisticsEntity {
  final int total;
  final int like;
  final int dislike;

  DashboardStatisticsEntity({
    required this.total,
    required this.like,
    required this.dislike,
  });

  @override
  String toString() {
    return 'DashboardStatisticEntity{total: $total, like: $like, dislike: $dislike}';
  }
}