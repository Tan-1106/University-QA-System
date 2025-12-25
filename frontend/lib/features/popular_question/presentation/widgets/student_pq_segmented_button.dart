import 'package:flutter/material.dart';

enum StudentPQSegmentedButtonOptions { all, faculty }

class StudentPqSegmentedButton extends StatefulWidget {
  final Function(String type) onTypeSelected;

  const StudentPqSegmentedButton({super.key, required this.onTypeSelected});

  @override
  State<StudentPqSegmentedButton> createState() => _StudentPqSegmentedButtonState();
}

class _StudentPqSegmentedButtonState extends State<StudentPqSegmentedButton> {
  StudentPQSegmentedButtonOptions _selected = StudentPQSegmentedButtonOptions.all;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<StudentPQSegmentedButtonOptions>(
        style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primaryContainer;
            }
            return Theme.of(context).colorScheme.surface;
          },
        )),
        segments: [
          ButtonSegment(
            value: StudentPQSegmentedButtonOptions.all,
            label: Text(
              'Tất cả câu hỏi',
            ),
          ),
          ButtonSegment(
            value: StudentPQSegmentedButtonOptions.faculty,
            label: Text(
              'Câu hỏi khoa',
            ),
          ),
        ],
        selected: {_selected},
        onSelectionChanged: (Set<StudentPQSegmentedButtonOptions> newSelection) {
          setState(() {
            widget.onTypeSelected(newSelection.first == StudentPQSegmentedButtonOptions.all ? 'all' : 'faculty');
            _selected = newSelection.first;
          });
        },
      ),
    );
  }
}