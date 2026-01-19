import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/utils/show_snackbar.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/widgets/sign_in_button.dart';
import 'package:university_qa_system/features/authentication/presentation/widgets/elit_sign_in_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPage> {
  void _handleELITSignInClick(BuildContext context) async {
    final result = await context.pushNamed<Map<String, dynamic>>('authWebview');

    if (!context.mounted || result == null) return;

    if (result.containsKey('error')) {
      showErrorSnackBar(
        context,
        'Đăng nhập với ELIT thất bại, vui lòng thử lại sau.',
      );
      return;
    }

    final String? serverCode = result['code'];
    if (serverCode == null) {
      showErrorSnackBar(
        context,
        'Không thể lấy mã xác thực, vui lòng thử lại sau.',
      );
      return;
    }

    context.read<AuthBloc>().add(
      SignInWithELITEvent(
        authCode: serverCode,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(VerifyUserAccessEvent());
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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Center(
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
                  const SizedBox(height: 10),
                  Text(
                    'Vui lòng đăng nhập để tiếp tục',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 340,
                    child: SignInButton(
                      onSignInClick: () => context.push('/system-sign-in'),
                    ),
                  ),
                  SizedBox(
                    width: 340,
                    child: ElitSignInButton(
                      onSignInClick: () => _handleELITSignInClick(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
