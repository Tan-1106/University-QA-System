import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key_list.dart';

abstract interface class APIManagementRepository {
  // Add a new API key
  Future<Either<Failure, String>> addAPIKey({
    required String name,
    String? description,
    required String provider,
    required String apiKey,
  });

  // Get a paginated list of API keys with optional filtering by provider and keyword
  Future<Either<Failure, APIKeyListEntity>> getAPIKeys({
    int page = 1,
    String? provider,
    String? keyword,
  });

  // Get API key details by ID
  Future<Either<Failure, APIKeyEntity>> getAPIKeyById({
    required String id,
  });

  // Get available models for a given API key and provider
  Future<Either<Failure, List<String>>> getKeyModels({
    required String key,
    required String provider,
  });

  // Add a model to an existing API key
  Future<Either<Failure, void>> addKeyModel({
    required String id,
    required String model,
  });

  // Toggle the usage status of an API key
  Future<Either<Failure, void>> toggleUsingKey({
    required String id,
  });

  // Delete an API key by ID
  Future<Either<Failure, void>> deleteAPIKey({
    required String id,
  });
}
