import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/core/utils/logger.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/widgets/sign_in_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  void _handleSignInClick(BuildContext context) async {
    final result = await context.push<Map<String, dynamic>>('/login/auth-webview');

    if (!context.mounted) return;
    if (result == null) return;
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng nhập: ${result['error']}')),
      );
      return;
    }

    final String? serverCode = result['code'];
    if (serverCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi hệ thống: Không nhận được mã xác thực.')),
      );
      return;
    }

    logger.i('ELIT Authentication successful. Authorization code: $serverCode');
    context.read<AuthBloc>().add(AuthGetUserInformation(authCode: serverCode));
  }

  @override
  Widget build(context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 20,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                brightness == Brightness.light ? 'assets/images/welcome_illustration_light.png' : 'assets/images/welcome_illustration_dark.png',
                width: 250,
                height: 250,
              ),
              Text(
                'Chào mừng!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(height: 10),
              Text(
                'Vui lòng đăng nhập để tiếp tục',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              Spacer(),
              SizedBox(
                width: 340,
                child: SignInButton(
                  onSignInClick: () => _handleSignInClick(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
