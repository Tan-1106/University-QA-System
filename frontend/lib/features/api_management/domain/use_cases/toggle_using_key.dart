import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class ToggleUsingKeyUseCase implements UseCase<void, ToggleUsingKeyUseCaseParams> {
  final APIManagementRepository repository;

  ToggleUsingKeyUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ToggleUsingKeyUseCaseParams params) {
    return repository.toggleUsingKey(id: params.id);
  }
}

class ToggleUsingKeyUseCaseParams {
  final String id;

  ToggleUsingKeyUseCaseParams({required this.id});
}

