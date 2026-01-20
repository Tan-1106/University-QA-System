class FiltersEntity {
  final List<String> existingDepartments;
  final List<String> existingDocumentTypes;
  final List<String> existingFaculties;

  FiltersEntity({
    required this.existingDepartments,
    required this.existingDocumentTypes,
    required this.existingFaculties,
  });

  @override
  String toString() {
    return 'FiltersEntity{existingDepartments: $existingDepartments, existingDocumentTypes: $existingDocumentTypes, existingFaculties: $existingFaculties}';
  }
}