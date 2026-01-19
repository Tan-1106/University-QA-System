import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final VoidCallback onSignInClick;

  const SignInButton({super.key, required this.onSignInClick});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onSignInClick,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
      ),
      child: Text(
        'Đăng nhập',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
