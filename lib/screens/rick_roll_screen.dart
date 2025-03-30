import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class RickRollScreen extends StatefulWidget {
  const RickRollScreen({super.key});

  @override
  State<RickRollScreen> createState() => _RickRollScreenState();
}

class _RickRollScreenState extends State<RickRollScreen> {
  // YouTube video ID for the new video
  final String _youtubeVideoId = 'BBJa32lCaaY';
  late YoutubePlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    // Set device to landscape mode for better video viewing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: _youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
        enableCaption: true,
      ),
    );

    // Add listener to check when video is ready
    _controller.setFullScreenListener((isFullScreen) {
      setState(() {
        _isReady = true;
      });
    });
  }

  @override
  void dispose() {
    // Return to portrait mode when navigating away
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Your Ghibli Art Is Ready!',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(child: player),
        );
      },
    );
  }
}
