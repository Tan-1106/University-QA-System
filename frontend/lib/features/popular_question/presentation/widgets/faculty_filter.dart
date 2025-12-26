import 'package:flutter/material.dart';

class FacultyFilter extends StatefulWidget {
  final Function(String faculty) onFacultySelected;

  const FacultyFilter({super.key, required this.onFacultySelected});

  @override
  State<FacultyFilter> createState() => _FacultyFilterState();
}

class _FacultyFilterState extends State<FacultyFilter> {
  String selectedFaculty = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
