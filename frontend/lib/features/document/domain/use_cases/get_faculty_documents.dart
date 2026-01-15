import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';


class GetFacultyDocumentsUseCase implements UseCase<Documents, GetFacultyDocumentsParams> {
  final DocumentRepository documentRepository;

  const GetFacultyDocumentsUseCase(this.documentRepository);

  @override
  Future<Either<Failure, Documents>> call(GetFacultyDocumentsParams params) {
    return documentRepository.loadFacultyDocuments(
      page: params.page,
      keyword: params.keyword,
      documentType: params.documentType,
      faculty: params.faculty,
    );
  }
}


class GetFacultyDocumentsParams {
  final int page;
  final String? keyword;
  final String? documentType;
  final String? faculty;

  const GetFacultyDocumentsParams({
    this.page = 1,
    this.keyword,
    this.documentType,
    this.faculty,
  });
}