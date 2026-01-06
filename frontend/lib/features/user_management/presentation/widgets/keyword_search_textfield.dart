import 'package:flutter/material.dart';

class KeywordSearchTextfield extends StatefulWidget {
  final Function(String keyword)? onKeywordChanged;

  const KeywordSearchTextfield({super.key, required this.onKeywordChanged});

  @override
  State<KeywordSearchTextfield> createState() => _KeywordSearchTextfieldState();
}

class _KeywordSearchTextfieldState extends State<KeywordSearchTextfield> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        widget.onKeywordChanged?.call(value);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        hintText: 'Nhập từ khóa...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            widget.onKeywordChanged?.call('');
          },
        ),
      ),
    );
  }
}
