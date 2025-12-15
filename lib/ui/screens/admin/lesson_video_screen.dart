import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/models/lesson.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonVideoScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonVideoScreen({super.key, required this.lesson});

  @override
  State<LessonVideoScreen> createState() => _LessonVideoScreenState();
}

class _LessonVideoScreenState extends State<LessonVideoScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.lesson.url ?? '');

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: true,
        showLiveFullscreenButton: false,
        controlsVisibleAtStart: false,
      ),
    );

    /// 🚀 FORCE LANDSCAPE IMMEDIATELY
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();

    /// Lock app back to portrait when leaving video
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _controller.value.isFullScreen
              ? null
              : AppBar(
                  title: AppText.interMedium(widget.lesson.title),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
          body: _controller.value.isFullScreen
              ? Center(child: player)
              : Column(
                  children: [
                    player,
                    SizedBox(height: 20),

                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: AppText.interLarger(widget.lesson.title),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
