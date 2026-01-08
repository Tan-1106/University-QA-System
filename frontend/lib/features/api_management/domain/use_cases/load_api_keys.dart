import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_keys.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class LoadAPIKeysUseCase implements UseCase<APIKeys, LoadAPIKeysUseCaseParams> {
  final APIManagementRepository repository;

  LoadAPIKeysUseCase(this.repository);

  @override
  Future<Either<Failure, APIKeys>> call(LoadAPIKeysUseCaseParams params) {
    return repository.loadAPIKeys(
      page: params.page,
      provider: params.provider,
      keyword: params.keyword,
    );
  }
}

class LoadAPIKeysUseCaseParams {
  final int page;
  final String? provider;
  final String? keyword;

  LoadAPIKeysUseCaseParams({
    this.page = 1,
    this.provider,
    this.keyword,
  });
}

