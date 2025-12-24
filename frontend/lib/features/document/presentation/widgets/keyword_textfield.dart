import 'package:flutter/material.dart';

class KeywordTextfield extends StatefulWidget {
  final Function(String keyword)? onKeywordChanged;

  const KeywordTextfield({super.key, required this.onKeywordChanged});

  @override
  State<KeywordTextfield> createState() => _KeywordTextfieldState();
}

class _KeywordTextfieldState extends State<KeywordTextfield> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tìm kiếm theo từ khóa:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
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
        ),
      ],
    );
  }
}
