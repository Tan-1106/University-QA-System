import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';


class UpdateDocumentBasicInfoUseCase implements UseCase<bool, UpdateDocumentBasicInfoParams> {
  final DocumentRepository documentRepository;

  const UpdateDocumentBasicInfoUseCase(this.documentRepository);

  @override
  Future<Either<Failure, bool>> call(UpdateDocumentBasicInfoParams params) {
    return documentRepository.updateDocumentBasicInfo(
      documentId: params.documentId,
      title: params.title,
      documentType: params.documentType,
      department: params.department,
      faculty: params.faculty,
      fileUrl: params.fileUrl,
    );
  }
}

class UpdateDocumentBasicInfoParams {
  final String documentId;
  final String? title;
  final String? documentType;
  final String? department;
  final String? faculty;
  final String? fileUrl;

  UpdateDocumentBasicInfoParams({
    required this.documentId,
    this.title,
    this.documentType,
    this.department,
    this.faculty,
    this.fileUrl,
  });
}