import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final void Function() onSignInClick;

  const SignInButton({super.key, required this.onSignInClick});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onSignInClick,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
      ),
      child: Text(
        'Đăng nhập với ELIT',
      ),
    );
  }
}
