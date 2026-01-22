import 'package:university_qa_system/features/api_management/domain/entities/api_key.dart';

class APIKeyListEntity {
  final List<APIKeyEntity> apiKeys;
  final int total;
  final int totalPages;
  final int currentPage;

  APIKeyListEntity({
    required this.apiKeys,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  String toString() {
    return 'APIKeyListEntity{total: $total, totalPages: $totalPages, currentPage: $currentPage, apiKeys: $apiKeys}';
  }
}