import 'config/theme/theme.dart';
import 'core/utils/create_theme.dart';
import 'package:flutter/material.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/sign_in_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Arimo", "Nunito");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'University Q&A System',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: SignInPage(),
    );
  }
}
