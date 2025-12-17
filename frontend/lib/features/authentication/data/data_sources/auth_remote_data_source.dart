import 'package:http/http.dart' as http;
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/authentication/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> getUserInformation(String authCode);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> getUserInformation(String authCode) async {
    try {

      return UserModel(sub: "PLACEHOLDER");
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
