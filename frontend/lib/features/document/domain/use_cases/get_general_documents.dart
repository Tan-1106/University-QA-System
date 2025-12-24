import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';


class GetGeneralDocumentsUseCase implements UseCase<Documents, GetGeneralDocumentsParams> {
  final DocumentRepository documentRepository;

  const GetGeneralDocumentsUseCase(this.documentRepository);

  @override
  Future<Either<Failure, Documents>> call(GetGeneralDocumentsParams params) {
    return documentRepository.loadGeneralDocuments(
      keyword: params.keyword,
      department: params.department,
      documentType: params.documentType,
    );
  }
}

class GetGeneralDocumentsParams {
  final int page;
  final String? keyword;
  final String? department;
  final String? documentType;

  const GetGeneralDocumentsParams({
    this.page = 1,
    this.keyword,
    this.department,
    this.documentType,
  });
}