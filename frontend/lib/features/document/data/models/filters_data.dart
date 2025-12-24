import 'package:university_qa_system/features/document/domain/entities/filters.dart';

class FiltersData {
  final List<String> existingDepartments;
  final List<String> existingDocumentTypes;

  FiltersData({
    required this.existingDepartments,
    required this.existingDocumentTypes,
  });

  Filters toEntity() {
    return Filters(
      existingDepartments: existingDepartments,
      existingDocumentTypes: existingDocumentTypes,
    );
  }

  @override
  String toString() {
    return 'FiltersData{existingDepartments: $existingDepartments, existingDocumentTypes: $existingDocumentTypes}';
  }
}