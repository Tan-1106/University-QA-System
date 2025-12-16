import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/authentication/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> loginWithELIT();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> loginWithELIT() async {
    try {
      return UserModel(sub: "PLACEHOLDER");
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}