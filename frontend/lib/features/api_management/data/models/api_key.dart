import 'package:university_qa_system/features/api_management/domain/entities/api_key.dart';

class APIKeyModel {
  final String id;
  final String name;
  final String? description;
  final String key;
  final String provider;
  final bool isUsing;
  final String? usingModel;

  APIKeyModel({
    required this.id,
    required this.name,
    this.description,
    required this.key,
    required this.provider,
    required this.isUsing,
    this.usingModel,
  });

  factory APIKeyModel.fromJson(Map<String, dynamic> json) {
    return APIKeyModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      key: json['api_key'] as String,
      provider: json['provider'] as String,
      isUsing: json['is_using'] as bool,
      usingModel: json['using_model'] as String?,
    );
  }

  APIKeyEntity toEntity() {
    return APIKeyEntity(
      id: id,
      name: name,
      description: description,
      key: key,
      provider: provider,
      isUsing: isUsing,
      usingModel: usingModel,
    );
  }
}