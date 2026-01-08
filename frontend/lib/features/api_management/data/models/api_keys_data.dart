import 'package:university_qa_system/features/api_management/domain/entities/api_keys.dart';

class APIKeysData {
  final List<APIKey> apiKeys;
  final int total;
  final int totalPages;
  final int currentPage;

  APIKeysData({
    required this.apiKeys,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory APIKeysData.fromJson(Map<String, dynamic> json) {
    var apiKeysJson = json['api_keys'] as List<dynamic>;
    List<APIKey> apiKeysList = apiKeysJson
    .map(
        (apiKeyJson) => APIKey(
          id: apiKeyJson['_id'] as String,
          name: apiKeyJson['name'] as String,
          description: apiKeyJson['description'] as String?,
          key: apiKeyJson['api_key'] as String,
          provider: apiKeyJson['provider'] as String,
          isUsing: apiKeyJson['is_using'] as bool,
          usingModel: apiKeyJson['using_model'] as String?,
        )
    ).toList();

    return APIKeysData(
      apiKeys: apiKeysList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  APIKeys toEntity() {
    return APIKeys(
      apiKeys: apiKeys,
      total: total,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  String toString(){
    return 'APIKeysData(apiKeys: $apiKeys, total: $total, totalPages: $totalPages, currentPage: $currentPage)';
  }
}

class APIKeyData {
  final String id;
  final String name;
  final String? description;
  final String key;
  final String provider;
  final bool isUsing;
  final String? usingModel;

  APIKeyData({
    required this.id,
    required this.name,
    this.description,
    required this.key,
    required this.provider,
    required this.isUsing,
    this.usingModel,
  });

  factory APIKeyData.fromJson(Map<String, dynamic> json) {
    return APIKeyData(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      key: json['api_key'] as String,
      provider: json['provider'] as String,
      isUsing: json['is_using'] as bool,
      usingModel: json['using_model'] as String?,
    );
  }

  APIKey toEntity() {
    return APIKey(
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

