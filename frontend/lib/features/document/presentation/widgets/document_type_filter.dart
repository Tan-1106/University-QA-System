import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/document/presentation/provider/document_provider.dart';

class DocumentTypeFilter extends StatefulWidget {
  final String? selectedDocumentType;
  final Function(String type) onDocumentTypeSelected;
  const DocumentTypeFilter({super.key, this.selectedDocumentType, required this.onDocumentTypeSelected});

  @override
  State<DocumentTypeFilter> createState() => _DocumentTypeFilterState();
}

class _DocumentTypeFilterState extends State<DocumentTypeFilter> {
  late String selectedDocumentType = widget.selectedDocumentType ?? 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.read<DocumentProvider>();
    final documentTypes = documentProvider.documentTypes;

    List<String> existingDocumentTypes = ['Tất cả'];

    if (documentTypes.isNotEmpty) {
      existingDocumentTypes = existingDocumentTypes + documentTypes;
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Loại tài liệu:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: selectedDocumentType,
              hint: const Text('Chọn loại tài liệu'),
              elevation: 16,
              isExpanded: true,
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_drop_down),
              ),
              items: existingDocumentTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(value),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDocumentType = newValue!;
                });
                widget.onDocumentTypeSelected(newValue!);
              },
            ),
          ),
        ),
      ],
    );
  }
}
