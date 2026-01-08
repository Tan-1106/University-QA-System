import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class AddAPIKeyUseCase implements UseCase<bool, AddAPIKeyUseCaseParams> {
  final APIManagementRepository repository;

  AddAPIKeyUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(AddAPIKeyUseCaseParams params) {
    return repository.addAPIKey(
      name: params.name,
      description: params.description,
      provider: params.provider,
      apiKey: params.apiKey,
    );
  }
}

class AddAPIKeyUseCaseParams {
  final String name;
  final String? description;
  final String provider;
  final String apiKey;

  AddAPIKeyUseCaseParams({
    required this.name,
    this.description,
    required this.provider,
    required this.apiKey,
  });
}