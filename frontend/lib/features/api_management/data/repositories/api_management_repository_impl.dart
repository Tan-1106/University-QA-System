import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/api_management/data/data_sources/api_management_remote_data_source.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_keys.dart';
import 'package:university_qa_system/features/api_management/domain/repositories/api_management_repository.dart';

class APIManagementRepositoryImpl implements APIManagementRepository {
  final APIManagementRemoteDataSource remoteDataSource;

  const APIManagementRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<Either<Failure, APIKeys>> loadAPIKeys({
    int page = 1,
    String? provider,
    String? keyword,
  }) async {
    try {
      final apiKeys = await remoteDataSource.fetchAPIKeys(
        page: page,
        provider: provider,
        keyword: keyword,
      );
      return right(apiKeys.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, APIKey>> getAPIKeyById({
    required String id,
  }) async {
    try {
      final apiKey = await remoteDataSource.getKeyById(id: id);
      return right(apiKey.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addAPIKey({
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

  @override
  Future<Either<Failure, bool>> deleteAPIKey({
    required String id,
  }) async {
    try {
      final result = await remoteDataSource.deleteAPIKey(id: id);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

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

  @override
  Future<Either<Failure, bool>> addKeyModel({
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

  @override
  Future<Either<Failure, bool>> toggleUsingKey({
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
}
