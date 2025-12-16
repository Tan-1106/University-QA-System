import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/common/entities/user.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> loginWithELIT() async {
    try {
      final userData = await remoteDataSource.loginWithELIT();
      return right(userData);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}