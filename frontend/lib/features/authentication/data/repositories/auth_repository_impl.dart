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

  // Sign up with system account
  @override
  Future<Either<Failure, void>> signUpSystemAccount({
    required String name,
    required String email,
    required String studentId,
    required String faculty,
    required String password,
  }) async {
    try {
      await remoteDataSource.signUpSystemAccount(
        name: name,
        email: email,
        studentId: studentId,
        faculty: faculty,
        password: password,
      );
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Sign in with system account
  @override
  Future<Either<Failure, UserEntity>> signInWithSystemAccount({
    required String email,
    required String password,
  }) async {
    try {
      final tokens = await remoteDataSource.signInWithSystemAccount(
        email: email,
        password: password,
      );
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        return left(const Failure('Xác thực thất bại: Không nhận được token hợp lệ'));
      } else {
        await secureStorageService.saveTokens(tokens.accessToken, tokens.refreshToken);
      }

      final currentUser = await remoteDataSource.getUserInformation();
      final userEntity = currentUser.toEntity();
      return right(userEntity);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Sign in with ELIT
  @override
  Future<Either<Failure, UserEntity>> signInWithELIT({
    required String authCode,
  }) async {
    try {
      final userDetails = await remoteDataSource.signInWithELIT(
        authCode: authCode,
      );

      final tokens = userDetails.tokens;
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        return left(const Failure('Xác thực thất bại: Không nhận được token hợp lệ'));
      } else {
        await secureStorageService.saveTokens(tokens.accessToken, tokens.refreshToken);
      }

      final userEntity = userDetails.toEntity();
      return right(userEntity);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get current user information
  @override
  Future<Either<Failure, UserEntity>> getUserInformation() async {
    try {
      final currentUser = await remoteDataSource.getUserInformation();

      final userEntity = currentUser.toEntity();
      return right(userEntity);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Sign out (revoke tokens and clear local storage)
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final refreshToken = await secureStorageService.getRefreshToken();
      await secureStorageService.deleteAll();

      await remoteDataSource.signOut(
        refreshToken: refreshToken ?? '',
      );
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
