import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color circularColor;

  const Loader({super.key, this.circularColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(circularColor),
      ),
    );
  }
}
