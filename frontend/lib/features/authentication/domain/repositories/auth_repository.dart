import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, bool>> registerSystemAccount(
    String name,
    String email,
    String studentId,
    String faculty,
    String password,
  );

  Future<Either<Failure, User>> signInWithSystemAccount(
    String email,
    String password,
  );

  Future<Either<Failure, User>> signInWithELIT(String authCode);

  Future<Either<Failure, User>> getUserInformation();

  Future<Either<Failure, bool>> signOut();
}
