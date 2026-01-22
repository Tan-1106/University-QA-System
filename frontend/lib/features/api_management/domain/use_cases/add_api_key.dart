import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class AddAPIKeyUseCase implements UseCase<String, AddAPIKeyParams> {
  final APIManagementRepository repository;

  AddAPIKeyUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(AddAPIKeyParams params) {
    return repository.addAPIKey(
      name: params.name,
      description: params.description,
      provider: params.provider,
      apiKey: params.apiKey,
    );
  }
}

class AddAPIKeyParams {
  final String name;
  final String? description;
  final String provider;
  final String apiKey;

  AddAPIKeyParams({
    required this.name,
    this.description,
    required this.provider,
    required this.apiKey,
  });
}