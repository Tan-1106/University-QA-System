import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/statistic.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';

class LoadDashboardStatisticUseCase implements UseCase<Statistic, NoParams> {
  final DashboardRepository dashboardRepository;

  const LoadDashboardStatisticUseCase(this.dashboardRepository);

  @override
  Future<Either<Failure, Statistic>> call(NoParams params) {
    return dashboardRepository.loadStatisticData();
  }
}
