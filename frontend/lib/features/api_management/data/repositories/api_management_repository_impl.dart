import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/api_management/data/data_sources/api_management_remote_data_source.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key_list.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class APIManagementRepositoryImpl implements APIManagementRepository {
  final APIManagementRemoteDataSource remoteDataSource;

  const APIManagementRepositoryImpl(
    this.remoteDataSource,
  );

  // Add a new API key
  @override
  Future<Either<Failure, String>> addAPIKey({
    required String name,
    String? description,
    required String provider,
    required String apiKey,
  }) async {
    try {
      final result = await remoteDataSource.addAPIKey(
        name: name,
        description: description,
        provider: provider,
        apiKey: apiKey,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get a paginated list of API keys with optional filtering by provider and keyword
  @override
  Future<Either<Failure, APIKeyListEntity>> getAPIKeys({
    int page = 1,
    String? provider,
    String? keyword,
  }) async {
    try {
      final apiKeys = await remoteDataSource.getAPIKeys(
        page: page,
        provider: provider,
        keyword: keyword,
      );
      return right(apiKeys.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get API key details by ID
  @override
  Future<Either<Failure, APIKeyEntity>> getAPIKeyById({
    required String id,
  }) async {
    try {
      final apiKey = await remoteDataSource.getKeyById(id: id);
      return right(apiKey.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get available models for a specific API key and provider
  @override
  Future<Either<Failure, List<String>>> getKeyModels({
    required String key,
    required String provider,
  }) async {
    try {
      final models = await remoteDataSource.getKeyModels(
        key: key,
        provider: provider,
      );
      return right(models);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Add a new model to an existing API key
  @override
  Future<Either<Failure, void>> addKeyModel({
    required String id,
    required String model,
  }) async {
    try {
      final result = await remoteDataSource.addKeyModel(
        id: id,
        model: model,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Toggle the usage status of an API key
  @override
  Future<Either<Failure, void>> toggleUsingKey({
    required String id,
  }) async {
    try {
      final result = await remoteDataSource.toggleUsingKey(
        id: id,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Delete an API key by ID
  @override
  Future<Either<Failure, void>> deleteAPIKey({
    required String id,
  }) async {
    try {
      final result = await remoteDataSource.deleteAPIKey(id: id);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
