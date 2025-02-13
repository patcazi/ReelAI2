import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'profile_videos_screen.dart';
import 'ai_video_playback_screen.dart';

class AiImageUploadScreen extends StatefulWidget {
  const AiImageUploadScreen({super.key});

  @override
  State<AiImageUploadScreen> createState() => _AiImageUploadScreenState();
}

class _AiImageUploadScreenState extends State<AiImageUploadScreen> {
  String? _pickedImagePath;
  String? _uploadedImageUrl;
  String? _runwayVideoUrl;
  bool _isUploading = false;
  bool _isGenerating = false;
  bool _isPosting = false;

  Future<void> _postToProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _runwayVideoUrl == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await FirebaseFirestore.instance.collection('videos').add({
        'userId': user.uid,
        'videoUrl': _runwayVideoUrl,
        'thumbnailUrl': _uploadedImageUrl, // Use the original image as thumbnail
        'title': 'AI Generated Video',
        'timestamp': timestamp,
        'uploadDate': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted successfully!')),
        );
        Navigator.pop(context); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting video: $e')),
        );
      }
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  Future<void> _generateVideo() async {
    if (_uploadedImageUrl == null) return;

    setState(() {
      _isGenerating = true;
      _runwayVideoUrl = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://us-central1-reel-ai-4.cloudfunctions.net/generateRunwayVideo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageUrl': _uploadedImageUrl}),
      );

      debugPrint('Raw response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['videoUrl'] != null) {
        final ephemeralVideoUrl = data['videoUrl'] as String;
        
        // Store in Firestore
        await FirebaseFirestore.instance.collection('ai_videos').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'videoUrl': ephemeralVideoUrl,
          'thumbnailUrl': _uploadedImageUrl, // Use the original image as thumbnail
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        setState(() {
          _runwayVideoUrl = ephemeralVideoUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI Video posted!')),
          );
          
          // Navigate to ProfileVideosScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AiVideoPlaybackScreen(
                videoUrl: ephemeralVideoUrl,
                thumbnailUrl: _uploadedImageUrl!,
              ),
            ),
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating video: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
      _runwayVideoUrl = null; // Reset video URL when uploading new image
    });

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
      
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
        _uploadedImageUrl = null; // Reset URL when picking new image
        _runwayVideoUrl = null; // Reset video URL when picking new image
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate AI Video'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileVideosScreen()),
                    );
                  },
                  child: const Text('View Generated Videos'),
                ),
                if (_pickedImagePath != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: Image.file(
                      File(_pickedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // const SizedBox(height: 10),
                  // Text(
                  //   'Selected image: ${_pickedImagePath!.split('/').last}',
                  //   style: Theme.of(context).textTheme.bodyMedium,
                  //   textAlign: TextAlign.center,
                  // ),
                ],
                if (_isUploading) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  const Text('Uploading...'),
                ],
                if (_uploadedImageUrl != null) ...[
                  const SizedBox(height: 20),
                  // Text(
                  //   'Public URL: $_uploadedImageUrl',
                  //   style: Theme.of(context).textTheme.bodyMedium,
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _generateVideo,
                    child: Text(_isGenerating ? 'Generating...' : 'Generate AI Video'),
                  ),
                ],
                if (_isGenerating) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  const Text('Generating video...'),
                ],
                if (_runwayVideoUrl != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Generated Video:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _runwayVideoUrl!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isPosting ? null : _postToProfile,
                    child: Text(_isPosting ? 'Posting...' : 'Post to Profile'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 