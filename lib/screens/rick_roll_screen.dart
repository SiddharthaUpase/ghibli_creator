import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RickRollScreen extends StatefulWidget {
  const RickRollScreen({super.key});

  @override
  State<RickRollScreen> createState() => _RickRollScreenState();
}

class _RickRollScreenState extends State<RickRollScreen> {
  // YouTube video ID for Rick Roll
  final String _youtubeVideoId = 'xvFZjo5PgG0';
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

    _controller = YoutubePlayerController(
      initialVideoId: _youtubeVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: true,
        loop: false,
        hideControls: false,
        hideThumbnail: true,
        forceHD: false,
      ),
    )..addListener(() {
      if (_controller.value.isReady && !_isReady) {
        setState(() {
          _isReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    // Return to portrait mode when navigating away
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          setState(() {
            _isReady = true;
          });
        },
      ),
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
          body: Center(
            child:
                _isReady
                    ? player
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          'Preparing your masterpiece...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
