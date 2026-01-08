class APIKeys {
  final List<APIKey> apiKeys;
  final int total;
  final int totalPages;
  final int currentPage;

  APIKeys({
    required this.apiKeys,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}

class APIKey {
  final String id;
  final String name;
  final String? description;
  final String key;
  final String provider;
  final bool isUsing;
  final String? usingModel;

  APIKey({
    required this.id,
    required this.name,
    this.description,
    required this.key,
    required this.provider,
    required this.isUsing,
    this.usingModel,
  });
}
