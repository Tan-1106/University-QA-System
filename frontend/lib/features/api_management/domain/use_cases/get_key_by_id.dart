import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key_list.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class GetKeyByIdUseCase implements UseCase<APIKeyEntity, GetKeyByIdUseCaseParams> {
  final APIManagementRepository repository;

  GetKeyByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, APIKeyEntity>> call(GetKeyByIdUseCaseParams params) {
    return repository.getAPIKeyById(id: params.id);
  }
}

class GetKeyByIdUseCaseParams {
  final String id;

  GetKeyByIdUseCaseParams({required this.id});
}

