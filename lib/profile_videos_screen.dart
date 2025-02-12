import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ai_video_playback_screen.dart';

class ProfileVideosScreen extends StatefulWidget {
  const ProfileVideosScreen({super.key});

  @override
  State<ProfileVideosScreen> createState() => _ProfileVideosScreenState();
}

class _ProfileVideosScreenState extends State<ProfileVideosScreen> {
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My AI Videos'),
      ),
      body: userId == null
          ? const Center(child: Text('Please sign in to view your videos'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ai_videos')
                  .where('userId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final videos = snapshot.data?.docs ?? [];

                if (videos.isEmpty) {
                  return const Center(
                    child: Text(
                      'No AI videos yet. Try generating one!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index].data() as Map<String, dynamic>;
                    final thumbnailUrl = video['thumbnailUrl'] as String?;
                    final videoUrl = video['videoUrl'] as String?;
                    final timestamp = video['timestamp'] as int;

                    return GestureDetector(
                      onTap: videoUrl != null ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AiVideoPlaybackScreen(
                              videoUrl: videoUrl,
                              thumbnailUrl: thumbnailUrl ?? '',
                            ),
                          ),
                        );
                      } : null,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              if (thumbnailUrl != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    thumbnailUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Generated Video',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Created ${_formatTimestamp(timestamp)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (videoUrl != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              videoUrl,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.blue,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.play_circle_outline,
                                            color: Colors.blue[700],
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
} 