import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> getUserInformation(String authCode);
}