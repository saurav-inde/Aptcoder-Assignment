import 'dart:io';
import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LessonPdfScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const LessonPdfScreen({super.key, required this.title, required this.pdfUrl});

  @override
  State<LessonPdfScreen> createState() => _LessonPdfScreenState();
}

class _LessonPdfScreenState extends State<LessonPdfScreen> {
  String? _localPath;
  bool _loading = true;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/lesson.pdf');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _localPath = file.path;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText.interMedium(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: AppText.interSmall(
                  '${_currentPage + 1} / $_totalPages',
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _localPath == null
          ? const Center(
              child: Text(
                'Failed to load PDF',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : PDFView(
              filePath: _localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onRender: (pages) {
                setState(() => _totalPages = pages ?? 0);
              },
              onPageChanged: (page, _) {
                setState(() => _currentPage = page ?? 0);
              },
            ),
    );
  }
}
