import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/utils/format_date.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/core/common/widgets/primary_button.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_list/document_list_bloc.dart';
import 'package:university_qa_system/features/document/presentation/provider/document_provider.dart';
import 'package:university_qa_system/features/document/presentation/widgets/department_filter.dart';
import 'package:university_qa_system/features/document/presentation/widgets/document_segmented_button.dart';
import 'package:university_qa_system/features/document/presentation/widgets/document_type_filter.dart';
import 'package:university_qa_system/features/document/presentation/widgets/faculty_dropdown_filter.dart';

class AdminDocumentList extends StatefulWidget {
  final Function(String documentId) onDocumentTap;
  final DocumentSegmentedButtonOptions selectedOption;

  const AdminDocumentList({super.key, required this.onDocumentTap, required this.selectedOption});

  @override
  State<AdminDocumentList> createState() => _AdminDocumentListState();
}

class _AdminDocumentListState extends State<AdminDocumentList> {
  final ScrollController _scrollController = ScrollController();
  final _titleController = TextEditingController();
  final _newFileUrlController = TextEditingController();
  String _selectedDocType = '';
  String _selectedDepartmentOrFaculty = '';

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<DocumentListBloc>().state;
      if (state is DocumentListLoaded && state.hasMore && !state.isLoadingMore) {
        if (widget.selectedOption == DocumentSegmentedButtonOptions.general) {
          context.read<DocumentListBloc>().add(
            LoadGeneralDocumentsEvent(
              page: state.currentPage + 1,
              isLoadMore: true,
            ),
          );
        } else if (widget.selectedOption == DocumentSegmentedButtonOptions.faculty) {
          context.read<DocumentListBloc>().add(
            LoadFacultyDocumentsEvent(
              page: state.currentPage + 1,
              isLoadMore: true,
            ),
          );
        }
      }
    }
  }

  void _showEditDocumentSheet(BuildContext context, Document document) {
    _titleController.text = document.fileName;
    _selectedDocType = document.docType;
    _selectedDepartmentOrFaculty = (widget.selectedOption == DocumentSegmentedButtonOptions.general ? document.department : document.faculty)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              Text(
                'Chỉnh sửa tài liệu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(),
              TextFormField(
                maxLines: 5,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên tài liệu',
                  border: OutlineInputBorder(),
                ),
              ),
              if (widget.selectedOption == DocumentSegmentedButtonOptions.general)
                DepartmentFilter(
                  selectedDepartment: _selectedDepartmentOrFaculty,
                  onDepartmentSelected: (department) {
                    _selectedDepartmentOrFaculty = department;
                  },
                ),
              if (widget.selectedOption == DocumentSegmentedButtonOptions.faculty)
                FacultyDropdownFilter(
                  selectedFaculty: _selectedDepartmentOrFaculty,
                  onFacultySelected: (faculty) {
                    _selectedDepartmentOrFaculty = faculty;
                  },
                ),
              DocumentTypeFilter(
                selectedDocumentType: _selectedDocType,
                onDocumentTypeSelected: (docType) {
                  _selectedDocType = docType;
                },
              ),
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Loại tài liệu:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 2,
                    controller: _newFileUrlController,
                    decoration: const InputDecoration(
                      labelText: '(Bỏ trống nếu không thay đổi)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              PrimaryButton(
                label: 'Cập nhật tài liệu',
                onPressed: () {
                  context.read<DocumentProvider>().updateDocumentBasicInfo(
                    documentId: document.id,
                    title: _titleController.text,
                    documentType: _selectedDocType,
                    department: widget.selectedOption == DocumentSegmentedButtonOptions.general ? _selectedDepartmentOrFaculty : null,
                    faculty: widget.selectedOption == DocumentSegmentedButtonOptions.faculty ? _selectedDepartmentOrFaculty : null,
                    fileUrl: _newFileUrlController.text.isNotEmpty ? _newFileUrlController.text : null,
                  );
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDeleteDialog(String documentId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa tài liệu này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                context.read<DocumentListBloc>().add(DeleteDocumentEvent(documentId));
                Navigator.of(ctx).pop();
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentListBloc, DocumentListState>(
      buildWhen: (previous, current) => current is DocumentListLoading || current is DocumentListLoaded,
      builder: (context, state) {
        List<Document> documents = [];
        bool isLoadingMore = false;

        if (state is DocumentListLoaded) {
          documents = state.documents;
          isLoadingMore = state.isLoadingMore;
        }

        if (state is DocumentListLoading && documents.isEmpty) {
          return const Center(child: Loader());
        }

        if (documents.isEmpty && state is DocumentListLoaded) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Theme.of(context).hintColor),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy tài liệu nào.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: documents.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= documents.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Loader()),
              );
            }

            final document = documents[index];
            return Column(
              children: [
                InkWell(
                  onTap: () => widget.onDocumentTap(document.id),
                  child: ListTile(
                    title: Text(
                      document.fileName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            const SizedBox(height: 4),
                            if (widget.selectedOption == DocumentSegmentedButtonOptions.general)
                              Text(
                                'Phòng ban: ${document.department}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            if (widget.selectedOption == DocumentSegmentedButtonOptions.faculty)
                              Text(
                                'Khoa: ${document.faculty}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            Text(
                              'Loại tài liệu: ${document.docType}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              'Ngày đăng tải: ${formatDate(document.uploadedAt)}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                        Column(
                          spacing: 10,
                          children: [
                            InkWell(
                              onTap: () => _showEditDocumentSheet(context, document),
                              child: const Icon(Icons.edit),
                            ),
                            InkWell(
                              onTap: () => _showConfirmDeleteDialog(document.id),
                              child: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}
