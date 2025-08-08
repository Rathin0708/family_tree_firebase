import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:family_tree_firebase/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:family_tree_firebase/features/posts/domain/models/post_model.dart';
import 'package:family_tree_firebase/features/posts/data/services/post_service.dart';
import 'package:family_tree_firebase/features/stories/domain/models/story_model.dart';
import 'package:family_tree_firebase/features/stories/data/services/story_service.dart';
import 'package:family_tree_firebase/features/family/presentation/screens/create_family_screen.dart';
import 'package:family_tree_firebase/features/family/presentation/screens/join_family_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final StoryService _storyService = StoryService();
  String? _familyId;

  @override
  void initState() {
    super.initState();
    // Get familyId from auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState.status == AuthStatus.authenticated) {
        _loadFamilyId();
      }
    });
  }

  Future<void> _loadFamilyId() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
          
      if (userDoc.exists && mounted) {
        setState(() {
          _familyId = userDoc.data()?['familyId'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading family data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    
    // Show welcome screen if not authenticated
    if (authState.status != AuthStatus.authenticated) {
      return _buildWelcomeScreen();
    }
    
    // Show loading indicator while checking family status
    if (_familyId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Show family creation prompt if user is authenticated but has no family
    if (_familyId == null || _familyId!.isEmpty) {
      return _buildNoFamilyScreen();
    }

    // Show home feed if authenticated
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Family Feed',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stories Section
            _buildStoriesSection(),
            const Divider(height: 1),
            // Posts Feed
            _buildPostsFeed(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF6A11CB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStoriesSection() {
    return SizedBox(
      height: 100,
      child: StreamBuilder<List<StoryModel>>(
        stream: _familyId != null ? _storyService.getFamilyStories(_familyId!) : Stream.value([]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading stories'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stories = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return _buildStoryItem(story);
            },
          );
        },
      ),
    );
  }

  Widget _buildStoryItem(StoryModel story) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6A11CB),
                width: 2,
              ),
              image: story.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(story.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: story.imageUrl == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            story.userName.split(' ')[0],
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsFeed() {
    return StreamBuilder<List<PostModel>>(
      stream: _familyId != null ? _postService.getFamilyPosts(_familyId!) : Stream.value([]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading posts'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _buildPostItem(posts[index]);
          },
        );
      },
    );
  }

  Widget _buildNoFamilyScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.group_add,
                size: 80,
                color: Color(0xFF6A11CB),
              ),
              const SizedBox(height: 20),
              Text(
                'Join or Create a Family',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'To start sharing moments with your family, you need to join an existing family or create a new one.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinFamilyScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Join Family'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateFamilyScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: Color(0xFF6A11CB)),
                  ),
                  child: const Text(
                    'Create Family',
                    style: TextStyle(color: Color(0xFF6A11CB)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreatePostDialog() async {
    final TextEditingController _postController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Post'),
          content: TextField(
            controller: _postController,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_postController.text.trim().isNotEmpty) {
                  try {
                    await _postService.createPost(
                      content: _postController.text.trim(),
                      familyId: _familyId!,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post created successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating post: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
              ),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0x996A11CB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo and Title
              Column(
                children: [
                  // Replace with your app logo
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.family_restroom, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to Family Tree',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Connect with your family and create your family tree',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Join Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to join family screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6A11CB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Join Now',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Create Now Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateFamilyScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Create Family',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userImageUrl != null
                  ? NetworkImage(post.userImageUrl!)
                  : null,
              child: post.userImageUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              post.userName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
          
          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post.content),
          ),
          
          // Post Images (if any)
          if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: post.imageUrls!.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    post.imageUrls![index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
          
          // Post Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.likedBy.contains('userId') // TODO: Use actual userId
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.likedBy.contains('userId') // TODO: Use actual userId
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () {
                    // TODO: Implement like functionality
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    // TODO: Implement comment functionality
                  },
                ),
                const Spacer(),
                Text(
                  '${post.likesCount} likes • ${post.commentsCount} comments',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
