import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class GenerateTitleScreen extends StatefulWidget {
  final String videoUrl;
  final String videoId;

  const GenerateTitleScreen({
    super.key,
    required this.videoUrl,
    required this.videoId,
  });

  @override
  State<GenerateTitleScreen> createState() => _GenerateTitleScreenState();
}

class _GenerateTitleScreenState extends State<GenerateTitleScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _titleController = TextEditingController();
  String _status = "";

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller!.setLooping(true);
        _controller!.play();
      });
  }

  Future<void> _generateTitle() async {
    final uri = Uri.parse("https://generatetitlehashtags-ii5rz7vlrq-uc.a.run.app");
    try {
      setState(() {
        _status = "Generating title...";
      });
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"videoUrl": widget.videoUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _titleController.text = data["result"]?["data"] ?? "No data returned";
          _status = data["message"];
        });
      } else {
        setState(() {
          _status = "Error: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
    }
  }

  Future<void> _saveTitle() async {
    try {
      setState(() {
        _status = "Saving title...";
      });

      await FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.videoId)
        .update({'title': _titleController.text.trim()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _status = "Error saving title: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Title'),
      ),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Generated Title',
              ),
            ),
          ),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _status,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _status.startsWith('Error') ? Colors.red : Colors.green,
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _generateTitle,
                    child: const Text('Generate Title'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveTitle,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 