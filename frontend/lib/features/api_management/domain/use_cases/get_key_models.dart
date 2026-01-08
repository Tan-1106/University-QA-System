import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class GetKeyModelsUseCase implements UseCase<List<String>, GetKeyModelsUseCaseParams> {
  final APIManagementRepository repository;

  GetKeyModelsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<String>>> call(GetKeyModelsUseCaseParams params) {
    return repository.getKeyModels(
      key: params.key,
      provider: params.provider,
    );
  }
}

class GetKeyModelsUseCaseParams {
  final String key;
  final String provider;

  GetKeyModelsUseCaseParams({
    required this.key,
    required this.provider,
  });
}

