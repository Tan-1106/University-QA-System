import 'package:university_qa_system/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({required super.sub});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      sub: map['sub'] ?? '',
    );
  }
}
