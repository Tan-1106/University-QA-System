import 'package:flutter/material.dart';

class ElitSignInButton extends StatelessWidget {
  final VoidCallback onSignInClick;

  const ElitSignInButton({super.key, required this.onSignInClick});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onSignInClick,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
      ),
      child: Text(
        'Đăng nhập với ELIT',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
