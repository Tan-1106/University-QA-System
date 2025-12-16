import 'package:flutter/material.dart';
import '../widgets/sign_in_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

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
                brightness == Brightness.light
                    ? 'assets/images/welcome_illustration_light.png'
                    : 'assets/images/welcome_illustration_dark.png',
                width: 250,
                height: 250,
              ),
              Text(
                'Chào mừng!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Vui lòng đăng nhập để tiếp tục',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
              Spacer(),
              SizedBox(
                width: 340,
                child: SignInButton(
                  onSignInClick: () {
                    // TODO: EVENT HANDLING
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
