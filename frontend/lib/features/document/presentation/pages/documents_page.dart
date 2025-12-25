import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_filter/document_filter_bloc.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_list/document_list_bloc.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_viewer/document_viewer_bloc.dart';
import 'package:university_qa_system/features/document/presentation/widgets/department_filter.dart';
import 'package:university_qa_system/features/document/presentation/widgets/document_list.dart';
import 'package:university_qa_system/features/document/presentation/widgets/document_segmented_button.dart';
import 'package:university_qa_system/features/document/presentation/widgets/document_type_filter.dart';
import 'package:university_qa_system/features/document/presentation/widgets/keyword_textfield.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  DocumentSegmentedButtonOptions _selectedType = DocumentSegmentedButtonOptions.general;
  String? _selectedDepartment;
  String? _selectedDocumentType;
  String? _keyword;

  @override
  void initState() {
    super.initState();
    context.read<DocumentFilterBloc>().add(GetDocumentFiltersEvent());
    _triggerSearch();
  }

  void _showFilterSheet(BuildContext context) {
    String? tempDepartment = _selectedDepartment;
    String? tempDocumentType = _selectedDocumentType;
    String? tempKeyword = _keyword;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    Text(
                      'Bộ lọc tài liệu',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    if (_selectedType == DocumentSegmentedButtonOptions.general)
                      DepartmentFilter(
                        onDepartmentSelected: (department) {
                          setSheetState(() {
                            tempDepartment = department != 'Tất cả' ? department : null;
                          });
                        },
                      ),
                    DocumentTypeFilter(
                      onDocumentTypeSelected: (documentType) {
                        setSheetState(() {
                          tempDocumentType = documentType != 'Tất cả' ? documentType : null;
                        });
                      },
                    ),
                    KeywordTextfield(
                      onKeywordChanged: (keyword) {
                        setSheetState(() {
                          tempKeyword = keyword.isNotEmpty ? keyword : null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDepartment = tempDepartment;
                            _selectedDocumentType = tempDocumentType;
                            _keyword = tempKeyword;
                          });
                          Navigator.of(context).pop();
                          _triggerSearch();
                        },
                        child: Text('Áp dụng bộ lọc'),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDepartment = null;
                            _selectedDocumentType = null;
                            _keyword = null;
                          });
                          Navigator.of(context).pop();
                          _triggerSearch();
                        },
                        child: Text('Hủy lọc'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _triggerSearch() {
    if (_selectedType == DocumentSegmentedButtonOptions.general) {
      context.read<DocumentListBloc>().add(
        LoadGeneralDocumentsEvent(
          department: _selectedDepartment,
          documentType: _selectedDocumentType,
          keyword: _keyword,
        ),
      );
    } else {
      context.read<DocumentListBloc>().add(
        LoadFacultyDocumentsEvent(
          documentType: _selectedDocumentType,
          keyword: _keyword,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFilterSheet(context),
        label: const Text('Lọc & tìm kiếm'),
        icon: Icon(Icons.filter_list),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DocumentSegmentedButton(
              onTypeSelected: (selectedType) {
                setState(() {
                  _selectedType = selectedType == 'general' ? DocumentSegmentedButtonOptions.general : DocumentSegmentedButtonOptions.faculty;
                  _keyword = null;
                  _selectedDepartment = null;
                  _selectedDocumentType = null;
                });
                context.read<DocumentListBloc>().add(ResetDocumentListEvent());
                _triggerSearch();
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: DocumentList(
                onDocumentTap: (documentId) {
                  context.read<DocumentViewerBloc>().add(LoadDocumentEvent(documentId));
                  context.push('/document-viewer');
                },
                selectedOption: _selectedType,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
