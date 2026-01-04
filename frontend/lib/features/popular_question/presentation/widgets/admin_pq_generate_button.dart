import 'package:flutter/material.dart';

class AdminPQGenerateButton extends StatefulWidget {
  final Function() onPressed;

  const AdminPQGenerateButton({super.key, required this.onPressed});

  @override
  State<AdminPQGenerateButton> createState() => _AdminPQGenerateButtonState();
}

class _AdminPQGenerateButtonState extends State<AdminPQGenerateButton> {
  void _showGeneratingToast() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Đang thực hiện thống kê, vui lòng quay lại sau...'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        spacing: 5,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Thống kê câu hỏi phổ biến:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showGeneratingToast();
                widget.onPressed();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Thực hiện thống kê'),
            ),
          )
        ],
      ),
    );
  }
}
