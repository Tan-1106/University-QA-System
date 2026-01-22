import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class AddKeyModelUseCase implements UseCase<void, AddKeyModelUseCaseParams> {
  final APIManagementRepository repository;

  AddKeyModelUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(AddKeyModelUseCaseParams params) {
    return repository.addKeyModel(
      id: params.id,
      model: params.model,
    );
  }
}

class AddKeyModelUseCaseParams {
  final String id;
  final String model;

  AddKeyModelUseCaseParams({
    required this.id,
    required this.model,
  });
}

