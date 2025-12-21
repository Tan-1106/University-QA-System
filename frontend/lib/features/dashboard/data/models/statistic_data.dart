import 'package:university_qa_system/features/dashboard/domain/entities/statistic.dart';

class StatisticData {
  final int total;
  final int like;
  final int dislike;

  StatisticData({
    required this.total,
    required this.like,
    required this.dislike,
  });

  factory StatisticData.fromJson(Map<String, dynamic> json) {
    return StatisticData(
      total: json['total'] as int,
      like: json['like'] as int,
      dislike: json['dislike'] as int,
    );
  }

  Statistic toEntity() {
    return Statistic(
      total: total,
      like: like,
      dislike: dislike,
    );
  }

  @override
  String toString() {
    return 'StatisticDetails{total: $total, like: $like, dislike: $dislike}';
  }
}
