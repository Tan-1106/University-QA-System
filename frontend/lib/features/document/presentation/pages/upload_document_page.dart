import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:university_qa_system/core/common/widgets/primary_button.dart';
import 'package:university_qa_system/core/utils/show_snackbar.dart';
import 'package:university_qa_system/features/document/presentation/provider/document_provider.dart';
import 'package:university_qa_system/features/document/presentation/widgets/department_filter.dart';
import 'package:university_qa_system/features/document/presentation/widgets/document_type_filter.dart';
import 'package:university_qa_system/features/document/presentation/widgets/faculty_dropdown_filter.dart';

class UploadDocumentPage extends StatefulWidget {
  const UploadDocumentPage({super.key});

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  File? _selectedFile;
  bool _isGeneralDocument = true;
  String? _selectedDocumentType;
  String? _selectedDepartment;
  String? _selectedFaculty;
  final _fileURLController = TextEditingController();

  Future<void> _pickPDFFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    setState(() {
      _selectedFile = File(path);
    });
  }

  void _submitUpload() {
    if (_selectedFile == null ||
        _selectedDocumentType == null ||
        (_isGeneralDocument && _selectedDepartment == null) ||
        (!_isGeneralDocument && _selectedFaculty == null) ||
        _fileURLController.text.isEmpty) {
      showErrorSnackBar(context, 'Vui lòng điền đầy đủ thông tin trước khi tải lên.');
      return;
    }

    final documentProvider = context.read<DocumentProvider>();
    documentProvider.upload(
      file: _selectedFile!,
      docType: _selectedDocumentType!,
      department: _isGeneralDocument ? _selectedDepartment : null,
      faculty: !_isGeneralDocument ? _selectedFaculty : null,
      fileUrl: _fileURLController.text,
    );
    showSuccessSnackBar(context, 'Tài liệu đang được tải lên. Vui lòng quay lại sau.');
    context.pop();
  }

  @override
  void dispose() {
    _fileURLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            spacing: 10,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn tài liệu để tải lên:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_selectedFile == null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Center(
                      child: Text(
                        'Chưa có tệp nào được chọn',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              if (_selectedFile != null)
                Text(
                  _selectedFile!.path.split('/').last,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickPDFFile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onTertiary,
                  ),
                  child: const Text('Chọn tệp'),
                ),
              ),
              const SizedBox(height: 10),
              DocumentTypeFilter(
                onDocumentTypeSelected: (String documentType) {
                  setState(() {
                    _selectedDocumentType = documentType;
                  });
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Phân loại tài liệu:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              RadioGroup<bool>(
                groupValue: _isGeneralDocument,
                onChanged: (value) {
                  setState(() {
                    _isGeneralDocument = value!;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text(
                          'Chung',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text(
                          'Khoa',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (_isGeneralDocument)
                DepartmentFilter(
                  onDepartmentSelected: (String department) {
                    setState(() {
                      _selectedDepartment = department;
                    });
                  },
                ),
              if (!_isGeneralDocument)
                FacultyDropdownFilter(
                  onFacultySelected: (String faculty) {
                    setState(() {
                      _selectedFaculty = faculty;
                    });
                  },
                ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Đường dẫn gốc đến tài liệu:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                controller: _fileURLController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'URL đến tài liệu được công khai...',
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Đăng tải',
                onPressed: _submitUpload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
