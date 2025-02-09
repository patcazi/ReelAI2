import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final storage = FirebaseStorage.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowTok',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                child: Text(
                  'GlowTok',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/Silhouette.png',
                  height: 400,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
          );
        }
      } catch (e) {
        // Handle errors as needed
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _screennameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Update the user's display name with the screenname
        await userCredential.user!.updateDisplayName(_screennameController.text.trim());
        // Navigate to WelcomeScreen on successful registration
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
          );
        }
      } catch (e) {
        // Handle errors as needed
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _screennameController,
                decoration: const InputDecoration(labelText: 'Screenname'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a screenname' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter an email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: const Center(
        child: Text('Welcome', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String username = "";

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      username = (currentUser?.displayName?.isNotEmpty ?? false)
          ? currentUser!.displayName!
          : "Superstar";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GlowTok',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Ready to Shine,',
                style: TextStyle(
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '$username?',
                style: const TextStyle(
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 300,
                child: Center(
                  child: Image.asset(
                    'assets/images/KatieProfilePic.png',
                    fit: BoxFit.contain,
                    width: 240,
                    height: 300,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UploadVideoScreen()),
                        );
                      },
                      child: const Text('Post Video'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to direct messages screen
                      },
                      child: const Text('Direct Messages'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                      },
                      child: const Text('Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  _UploadVideoScreenState createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  bool _isUploading = false;
  String? _uploadStatus;
  final TextEditingController _titleController = TextEditingController();

  Future<void> _pickAndUploadVideo() async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);
      
      if (video == null) return;

      setState(() {
        _isUploading = true;
        _uploadStatus = 'Uploading video...';
      });

      // Create a unique filename using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final thumbnailData = await VideoThumbnail.thumbnailData(
        video: video.path,        // The local path from image_picker
        imageFormat: ImageFormat.PNG,
        maxWidth: 512,            // or any desired thumbnail size
        quality: 90,              // 0-100 (higher = better quality)
      );

      if (thumbnailData == null) {
        // Handle the case if thumbnail generation failed
        return;
      }

      final thumbnailName = 'thumbnails/$userId/$timestamp.png';
      final thumbnailRef = FirebaseStorage.instance.ref().child(thumbnailName);

      final videoName = 'videos/$userId/$timestamp.mp4';

      // Upload to Firebase Storage
      final videoFile = File(video.path);
      final storageRef = FirebaseStorage.instance.ref().child(videoName);
      
      // Start upload
      final uploadTask = storageRef.putFile(
        videoFile,
        SettableMetadata(contentType: 'video/mp4'),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        setState(() {
          _uploadStatus = 'Uploading: ${progress.toStringAsFixed(1)}%';
        });
      });

      // Wait for upload to complete
      await uploadTask;
      
      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      await thumbnailRef.putData(
        thumbnailData,
        SettableMetadata(contentType: 'image/png'),
      );
      final thumbnailUrl = await thumbnailRef.getDownloadURL();

      // Save video metadata to Firestore
      await FirebaseFirestore.instance.collection('videos').add({
        'userId': userId,
        'videoUrl': downloadUrl,
        'thumbnailUrl': thumbnailUrl,
        'title': _titleController.text.trim(),
        'timestamp': timestamp,
        'uploadDate': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload complete!';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
      }

    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Video Title',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              setState(() {
                                _titleController.text += emoji.emoji;
                              });
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),
                ],
              ),
            ),
            if (_isUploading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_uploadStatus ?? 'Uploading...'),
                ],
              )
            else
              ElevatedButton(
                onPressed: _pickAndUploadVideo,
                child: const Text('Select Video from Gallery'),
              ),
            if (_uploadStatus != null && !_isUploading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_uploadStatus!),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      username = (currentUser?.displayName?.isNotEmpty ?? false)
          ? currentUser!.displayName!
          : "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data?.data() != null) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final aboutMe = data['aboutMe'] as String?;
                    if (aboutMe != null && aboutMe.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          aboutMe,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }
                  }
                  return const SizedBox(height: 30);
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('videos')
                    .where('userId', isEqualTo: userId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('DEBUG: Firestore error: ${snapshot.error}');
                    return const Center(
                      child: Text('Error loading videos'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Your videos will appear here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final video = snapshot.data!.docs[index];
                      final data = video.data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Untitled';
                      final timestamp = data['timestamp'] as int;
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final docs = snapshot.data!.docs;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScrollingVideosScreen(
                                    videos: docs,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      data['thumbnailUrl'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Video'),
                                    content: const Text('Are you sure you want to delete this video?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true && mounted) {
                                  try {
                                    // Delete from Storage
                                    await FirebaseStorage.instance
                                        .ref('videos/$userId/$timestamp.mp4')
                                        .delete();
                                    await FirebaseStorage.instance
                                        .ref('thumbnails/$userId/$timestamp.png')
                                        .delete();
                                    
                                    // Delete from Firestore
                                    await FirebaseFirestore.instance
                                        .collection('videos')
                                        .doc(video.id)
                                        .delete();
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error deleting video: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? videoId;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    this.videoId,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  Future<void> _handleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final videoId = widget.videoId;
    
    if (currentUser != null && videoId != null) {
      final likesRef = FirebaseFirestore.instance
          .collection('videos')
          .doc(videoId)
          .collection('likes')
          .doc(currentUser.uid);

      final doc = await likesRef.get();
      if (doc.exists) {
        // Unlike: delete the doc
        await likesRef.delete();
      } else {
        // Like: create the doc
        await likesRef.set({'timestamp': FieldValue.serverTimestamp()});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _controller.setLooping(true);
        setState(() {});
        _controller.play();
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
      appBar: AppBar(
        title: const Text('Glow Show'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (widget.videoId != null) StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('videos')
                        .doc(widget.videoId)
                        .collection('likes')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final likesSnapshot = snapshot.data;
                      final likesCount = likesSnapshot?.size ?? 0;
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final userHasLiked = currentUser != null && 
                          (likesSnapshot?.docs.any((doc) => doc.id == currentUser.uid) ?? false);

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              userHasLiked ? Icons.favorite : Icons.favorite_border,
                              color: userHasLiked ? Colors.red : null,
                            ),
                            onPressed: _handleLike,
                          ),
                          Text(
                            likesCount.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) {
      _profileNameController.text = user!.displayName!;
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(_profileNameController.text.trim());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'aboutMe': _aboutMeController.text.trim(),
        'displayName': _profileNameController.text.trim(),
      }, SetOptions(merge: true));
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _profileNameController,
              decoration: const InputDecoration(
                labelText: 'Profile Name',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aboutMeController,
                    decoration: const InputDecoration(
                      labelText: 'About Me',
                    ),
                    maxLines: 6,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return EmojiPicker(
                          onEmojiSelected: (category, emoji) {
                            setState(() {
                              _aboutMeController.text += emoji.emoji;
                            });
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollingVideosScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> videos;
  final int initialIndex;

  const ScrollingVideosScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  _ScrollingVideosScreenState createState() => _ScrollingVideosScreenState();
}

class _ScrollingVideosScreenState extends State<ScrollingVideosScreen> {
  late final List<QueryDocumentSnapshot> videos;
  late final int initialIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    videos = widget.videos;
    initialIndex = widget.initialIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final videoData = videos[index].data() as Map<String, dynamic>;
          return VideoPlayerScreen(
            videoUrl: videoData['videoUrl'],
            title: videoData['title'] ?? 'Untitled',
            videoId: videos[index].id,
          );
        },
      ),
    );
  }
}