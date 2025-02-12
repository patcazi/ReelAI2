import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'add_title_screen.dart';

class AiVideoPlaybackScreen extends StatefulWidget {
  final String videoUrl;

  const AiVideoPlaybackScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _AiVideoPlaybackScreenState createState() => _AiVideoPlaybackScreenState();
}

class _AiVideoPlaybackScreenState extends State<AiVideoPlaybackScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Video Playback')),
      body: Stack(
        children: [
          Center(
            child: _initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTitleScreen(videoUrl: widget.videoUrl),
                  ),
                );
              },
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      floatingActionButton: _initialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
} 