import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/user_management/presentation/bloc/user_management_bloc.dart';

class FacultyFilter extends StatefulWidget {
  final String? currentFaculty;
  final Function(String faculty) onFacultySelected;
  const FacultyFilter({super.key, required this.onFacultySelected, this.currentFaculty});

  @override
  State<FacultyFilter> createState() => _FacultyFilterState();
}

class _FacultyFilterState extends State<FacultyFilter> {
  String selectedFaculty = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserManagementBloc>().state;
    List<String> existingFaculties = ['Tất cả'];
    if (state is UserManagementStateLoaded) {
      existingFaculties = existingFaculties + state.faculties;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: widget.currentFaculty ?? selectedFaculty,
            hint: const Text('Chọn khoa'),
            elevation: 16,
            isExpanded: true,
            icon: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_drop_down),
            ),
            items:
                existingFaculties.map<DropdownMenuItem<String>>((String value) {
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
      );
    }

    return const Placeholder();
  }
}
