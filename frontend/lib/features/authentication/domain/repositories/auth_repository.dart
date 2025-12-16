import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/common/entities/user.dart';
import 'package:university_qa_system/core/error/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> loginWithELIT();
}