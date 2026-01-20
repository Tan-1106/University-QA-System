import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetStatisticsUseCase implements UseCase<DashboardStatisticsEntity, NoParams> {
  final DashboardRepository dashboardRepository;

  const GetStatisticsUseCase(this.dashboardRepository);

  @override
  Future<Either<Failure, DashboardStatisticsEntity>> call(NoParams params) {
    return dashboardRepository.getStatistics();
  }
}
