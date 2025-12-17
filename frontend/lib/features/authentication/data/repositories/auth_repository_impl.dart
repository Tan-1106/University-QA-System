import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/entities/user.dart';
import 'package:university_qa_system/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> getUserInformation(String authCode) async {
    try {
      final userData = await remoteDataSource.getUserInformation(authCode);
      return right(userData);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}