import 'package:university_qa_system/features/popular_question/domain/entities/faculty_list.dart';

class FacultyListModel {
  final List<String> faculties;

  FacultyListModel({required this.faculties});

  factory FacultyListModel.fromJson(Map<String, dynamic> json) {
    return FacultyListModel(
      faculties: List<String>.from(json['faculties'] ?? []),
    );
  }

  FacultyListEntity toEntity() {
    return FacultyListEntity(
      faculties: faculties,
    );
  }
}
