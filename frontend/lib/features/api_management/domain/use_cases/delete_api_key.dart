import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class DeleteAPIKeyUseCase implements UseCase<bool, DeleteAPIKeyUseCaseParams> {
  final APIManagementRepository repository;

  DeleteAPIKeyUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(DeleteAPIKeyUseCaseParams params) {
    return repository.deleteAPIKey(id: params.id);
  }
}

class DeleteAPIKeyUseCaseParams {
  final String id;

  DeleteAPIKeyUseCaseParams({required this.id});
}

