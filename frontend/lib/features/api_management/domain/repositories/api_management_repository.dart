import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_keys.dart';

abstract interface class APIManagementRepository {
  Future<Either<Failure, APIKeys>> loadAPIKeys({
    int page = 1,
    String? provider,
    String? keyword,
  });

  Future<Either<Failure, APIKey>> getAPIKeyById({
    required String id,
  });

  Future<Either<Failure, String>> addAPIKey({
    required String name,
    String? description,
    required String provider,
    required String apiKey,
  });

  Future<Either<Failure, bool>> deleteAPIKey({
    required String id,
  });

  Future<Either<Failure, List<String>>> getKeyModels({
    required String key,
    required String provider,
  });

  Future<Either<Failure, bool>> addKeyModel({
    required String id,
    required String model,
  });

  Future<Either<Failure, bool>> toggleUsingKey({
    required String id,
  });
}
