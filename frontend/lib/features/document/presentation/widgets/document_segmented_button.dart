import 'package:flutter/material.dart';

enum DocumentSegmentedButtonOptions { general, faculty }

class DocumentSegmentedButton extends StatefulWidget {
  final Function(String type) onTypeSelected;

  const DocumentSegmentedButton({super.key, required this.onTypeSelected});

  @override
  State<DocumentSegmentedButton> createState() => _DocumentSegmentedButtonState();
}

class _DocumentSegmentedButtonState extends State<DocumentSegmentedButton> {
  DocumentSegmentedButtonOptions _selected = DocumentSegmentedButtonOptions.general;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<DocumentSegmentedButtonOptions>(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primaryContainer;
              }
              return Theme.of(context).colorScheme.surface;
            },
          ),
        ),
        segments: const [
          ButtonSegment(
            value: DocumentSegmentedButtonOptions.general,
            label: Text(
              'Tài liệu chung',
            ),
          ),
          ButtonSegment(
            value: DocumentSegmentedButtonOptions.faculty,
            label: Text(
              'Tài liệu khoa',
            ),
          ),
        ],
        selected: {_selected},
        onSelectionChanged: (Set<DocumentSegmentedButtonOptions> newSelection) {
          setState(() {
            widget.onTypeSelected(newSelection.first == DocumentSegmentedButtonOptions.general ? 'general' : 'faculty');
            _selected = newSelection.first;
          });
        },
      ),
    );
  }
}
