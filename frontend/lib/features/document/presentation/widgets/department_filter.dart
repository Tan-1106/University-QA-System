import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/document/presentation/provider/document_provider.dart';

class DepartmentFilter extends StatefulWidget {
  final String? selectedDepartment;
  final Function(String deparment) onDepartmentSelected;
  const DepartmentFilter({super.key, this.selectedDepartment, required this.onDepartmentSelected});

  @override
  State<DepartmentFilter> createState() => _DepartmentFilterState();
}

class _DepartmentFilterState extends State<DepartmentFilter> {
  late String selectedDepartment = widget.selectedDepartment ?? 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.read<DocumentProvider>();
    final departments = documentProvider.departments;

    List<String> existingDepartments = ['Tất cả'];

    if (departments.isNotEmpty) {
      existingDepartments = existingDepartments + departments;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phòng ban:',
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
              value: selectedDepartment,
              hint: const Text('Chọn phòng ban'),
              elevation: 16,
              isExpanded: true,
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_drop_down),
              ),
              items: existingDepartments.map<DropdownMenuItem<String>>((String value) {
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
                  selectedDepartment = newValue!;
                });
                widget.onDepartmentSelected(newValue!);
              },
            ),
          ),
        ),
      ],
    );
  }
}
