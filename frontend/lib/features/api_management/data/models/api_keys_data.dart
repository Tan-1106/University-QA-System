import 'package:university_qa_system/features/api_management/data/models/api_key.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key_list.dart';

class APIKeyListModel {
  final List<APIKeyModel> apiKeys;
  final int total;
  final int totalPages;
  final int currentPage;

  APIKeyListModel({
    required this.apiKeys,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory APIKeyListModel.fromJson(Map<String, dynamic> json) {
    var apiKeysJson = json['api_keys'] as List<dynamic>;
    List<APIKeyModel> apiKeysList = apiKeysJson
    .map(
        (apiKeyJson) => APIKeyModel(
          id: apiKeyJson['_id'] as String,
          name: apiKeyJson['name'] as String,
          description: apiKeyJson['description'] as String?,
          key: apiKeyJson['api_key'] as String,
          provider: apiKeyJson['provider'] as String,
          isUsing: apiKeyJson['is_using'] as bool,
          usingModel: apiKeyJson['using_model'] as String?,
        )
    ).toList();

    return APIKeyListModel(
      apiKeys: apiKeysList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  APIKeyListEntity toEntity() {
    return APIKeyListEntity(
      apiKeys: apiKeys.map((apiKeyModel) => apiKeyModel.toEntity()).toList(),
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
