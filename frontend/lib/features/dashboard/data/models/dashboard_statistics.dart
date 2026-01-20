import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_statistics.dart';

class DashboardStatisticsModel {
  final int total;
  final int like;
  final int dislike;

  DashboardStatisticsModel({
    required this.total,
    required this.like,
    required this.dislike,
  });

  factory DashboardStatisticsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatisticsModel(
      total: json['total'] as int,
      like: json['like'] as int,
      dislike: json['dislike'] as int,
    );
  }

  DashboardStatisticsEntity toEntity() {
    return DashboardStatisticsEntity(
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
