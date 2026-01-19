import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';

abstract interface class AuthRepository {
  // Sign up with system account
  Future<Either<Failure, void>> signUpSystemAccount({
    required String name,
    required String email,
    required String studentId,
    required String faculty,
    required String password,
  });

  // Sign in with system account
  Future<Either<Failure, UserEntity>> signInWithSystemAccount({
    required String email,
    required String password,
  });

  // Sign in with ELIT
  Future<Either<Failure, UserEntity>> signInWithELIT({
    required String authCode,
  });

  // Get current user information
  Future<Either<Failure, UserEntity>> getUserInformation();

  // Sign out (revoke tokens and clear local storage)
  Future<Either<Failure, void>> signOut();
}
