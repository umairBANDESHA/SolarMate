import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbotWebView extends StatefulWidget {
  const ChatbotWebView({super.key});

  @override
  State<ChatbotWebView> createState() => _ChatbotWebViewState();
}

class _ChatbotWebViewState extends State<ChatbotWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(
            Uri.parse(
              'https://www.chatbase.co/chatbot-iframe/jdfA11shxIzz8Pc5H7Hfq',
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
