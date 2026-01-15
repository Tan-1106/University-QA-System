import 'package:flutter/material.dart';

class StatisticBox extends StatelessWidget {
  final int quantity;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  const StatisticBox({super.key, required this.quantity, required this.title, required this.backgroundColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
