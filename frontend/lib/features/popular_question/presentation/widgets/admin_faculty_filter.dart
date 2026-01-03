import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/admin_pq/admin_pq_bloc.dart';

class AdminFacultyFilter extends StatefulWidget {
  final String? selectedFaculty;
  final Function(String faculty) onFacultySelected;

  const AdminFacultyFilter({super.key, required this.selectedFaculty, required this.onFacultySelected});

  @override
  State<AdminFacultyFilter> createState() => _AdminFacultyFilterState();
}

class _AdminFacultyFilterState extends State<AdminFacultyFilter> {
  @override
  Widget build(BuildContext context) {
    final adminBlocState = context.watch<AdminPQBloc>().state;

    List<String> existingFaculties = ['Tất cả'];

    if (adminBlocState is AdminPQDataState) {
      existingFaculties = existingFaculties + adminBlocState.faculties;
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Lọc theo khoa:',
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
              value: widget.selectedFaculty ?? 'Tất cả',
              hint: const Text('Chọn khoa'),
              elevation: 16,
              isExpanded: true,
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_drop_down),
              ),
              items: existingFaculties.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(value),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                widget.onFacultySelected(newValue!);
              },
            ),
          ),
        ),
      ],
    );
  }
}
