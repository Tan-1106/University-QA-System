import 'package:university_qa_system/features/popular_question/domain/entities/existing_faculties.dart';

class ExistingFacultiesData {
  final List<String> faculties;

  ExistingFacultiesData({required this.faculties});

  factory ExistingFacultiesData.fromJson(Map<String, dynamic> json) {
    return ExistingFacultiesData(
      faculties: List<String>.from(json['faculties'] ?? []),
    );
  }

  ExistingFaculties toEntity() {
    return ExistingFaculties(
      faculties: faculties,
    );
  }
}
