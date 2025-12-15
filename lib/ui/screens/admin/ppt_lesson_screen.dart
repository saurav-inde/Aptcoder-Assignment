import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LessonPptScreen extends StatefulWidget {
  final String title;
  final String pptUrl;

  const LessonPptScreen({
    super.key,
    required this.title,
    required this.pptUrl,
  });

  @override
  State<LessonPptScreen> createState() => _LessonPptScreenState();
}

class _LessonPptScreenState extends State<LessonPptScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    /// Google Docs Viewer URL
    final viewerUrl =
        'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.pptUrl)}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText.interMedium(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
