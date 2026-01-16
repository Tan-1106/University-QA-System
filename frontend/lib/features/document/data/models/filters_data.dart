import 'package:university_qa_system/features/document/domain/entities/filters.dart';

class FiltersData {
  final List<String> existingDepartments;
  final List<String> existingDocumentTypes;
  final List<String> existingFaculties;

  FiltersData({
    required this.existingDepartments,
    required this.existingDocumentTypes,
    required this.existingFaculties,
  });

  Filters toEntity() {
    return Filters(
      existingDepartments: existingDepartments,
      existingDocumentTypes: existingDocumentTypes,
      existingFaculties: existingFaculties,
    );
  }

  @override
  String toString() {
    return 'FiltersData{existingDepartments: $existingDepartments, existingDocumentTypes: $existingDocumentTypes, existingFaculties: $existingFaculties}';
  }
}