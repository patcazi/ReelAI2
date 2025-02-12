import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTitleScreen extends StatefulWidget {
  final String videoUrl;

  const AddTitleScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _AddTitleScreenState createState() => _AddTitleScreenState();
}

class _AddTitleScreenState extends State<AddTitleScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                hintText: 'Enter a title for your video',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance.collection('videos').add({
                      'title': _titleController.text,
                      'videoUrl': widget.videoUrl,
                      'userId': FirebaseAuth.instance.currentUser!.uid,
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Posted successfully!')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error posting: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 