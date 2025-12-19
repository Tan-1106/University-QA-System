import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/services/secure_storage_service.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorageService;

  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.secureStorageService,
  );

  @override
  Future<Either<Failure, User>> signInWithELIT(String authCode) async {
    try {
      final userDetails = await remoteDataSource.signInWithELIT(authCode);

      final tokens = userDetails.tokens;
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        return left(Failure('Xác thực thất bại: Không nhận được token hợp lệ'));
      } else {
        await secureStorageService.saveTokens(tokens.accessToken, tokens.refreshToken);
      }

      final userEntity = userDetails.toEntity();
      return right(userEntity);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getUserInformation() async {
    try {
      final currentUser = await remoteDataSource.getUserInformation();

      final userEntity = currentUser.toEntity();
      return right(userEntity);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
