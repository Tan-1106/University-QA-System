import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:university_qa_system/features/document/presentation/provider/document_provider.dart';

class FacultyDropdownFilter extends StatefulWidget {
  final String? selectedFaculty;
  final Function(String faculty) onFacultySelected;
  const FacultyDropdownFilter({
    super.key,
    this.selectedFaculty,
    required this.onFacultySelected,
  });

  @override
  State<FacultyDropdownFilter> createState() => _FacultyDropdownFilterState();
}

class _FacultyDropdownFilterState extends State<FacultyDropdownFilter> {
  late String? selectedFaculty = widget.selectedFaculty;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentProvider>();

    if (provider.faculties.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc theo khoa:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Không có dữ liệu khoa',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }

    // Ensure selected faculty is valid
    if (selectedFaculty == null || !provider.faculties.contains(selectedFaculty)) {
      selectedFaculty = provider.faculties.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lọc theo khoa:',
          style: Theme.of(context).textTheme.bodyMedium,
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
              value: selectedFaculty,
              hint: const Text('Chọn khoa'),
              elevation: 16,
              isExpanded: true,
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_drop_down),
              ),
              items: provider.faculties.map<DropdownMenuItem<String>>((String value) {
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
                  selectedFaculty = newValue!;
                });
                widget.onFacultySelected(newValue!);
              },
            ),
          ),
        ),
      ],
    );
  }
}

