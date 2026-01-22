class APIKeyEntity {
  final String id;
  final String name;
  final String? description;
  final String key;
  final String provider;
  final bool isUsing;
  final String? usingModel;

  APIKeyEntity({
    required this.id,
    required this.name,
    this.description,
    required this.key,
    required this.provider,
    required this.isUsing,
    this.usingModel,
  });

  @override
  String toString() {
    return 'APIKeyEntity(id: $id, name: $name, description: $description, key: $key, provider: $provider, isUsing: $isUsing, usingModel: $usingModel)';
  }
}