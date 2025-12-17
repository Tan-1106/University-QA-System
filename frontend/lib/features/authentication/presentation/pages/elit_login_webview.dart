import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ElitLoginWebview extends StatefulWidget {
  const ElitLoginWebview({super.key});

  @override
  State<ElitLoginWebview> createState() {
    return _ElitLoginWebViewState();
  }
}

class _ElitLoginWebViewState extends State<ElitLoginWebview> {
  bool _isLoading = true;
  late final WebViewController _controller;
  final String clientState = Uuid().v4();
  final String clientId = dotenv.env['ELIT_CLIENT_ID'] ?? '';
  final String redirectUrl = dotenv.env['ELIT_CALLBACK_URL'] ?? '';
  final String authorizeEndpoint = '${dotenv.env['ELIT_BASE_URL']}/oauth2/v1/authorize';

  @override
  void initState() {
    super.initState();

    final Uri authUri = Uri.parse(authorizeEndpoint).replace(
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUrl,
        'response_type': 'code',
        'scope': 'openid profile email',
        'state': clientState,
      },
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.127 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => {
            setState(() {
              _isLoading = true;
            }),
          },
          onPageFinished: (String url) => {
            setState(() {
              _isLoading = false;
            }),
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(redirectUrl)) {
              final Uri uri = Uri.parse(request.url);
              final String? code = uri.queryParameters['code'];
              final String? error = uri.queryParameters['error'];

              if (code != null) {
                context.pop({'code': code});
              } else if (error != null) {
                context.pop({'error': error});
              } else {
                context.pop(null);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(authUri.toString()));
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng nhập với ELIT'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
