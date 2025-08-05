import 'package:flutter/material.dart';
import 'package:family_tree_firebase/core/constants/app_constants.dart';
import 'package:family_tree_firebase/features/home/domain/models/post_model.dart';
import 'package:family_tree_firebase/features/home/domain/models/story_model.dart';
import 'package:family_tree_firebase/features/home/presentation/widgets/post_widget.dart';
import 'package:family_tree_firebase/features/home/presentation/widgets/story_circle_widget.dart';
import 'package:family_tree_firebase/features/home/presentation/widgets/story_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Temporary mock data - in a real app, this would come from a repository
  final List<StoryModel> _stories = [
    StoryModel(
      id: '1',
      userId: 'user1',
      userName: 'John Doe',
      userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      imageUrl: 'https://picsum.photos/400/800',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isSeen: false,
    ),
    StoryModel(
      id: '2',
      userId: 'user2',
      userName: 'Jane Smith',
      userImageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      imageUrl: 'https://picsum.photos/400/801',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isSeen: false,
    ),
    StoryModel(
      id: '3',
      userId: 'user3',
      userName: 'Mike Johnson',
      userImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      imageUrl: 'https://picsum.photos/400/802',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isSeen: false,
      isLive: true,
    ),
  ];

  final List<PostModel> _posts = [
    PostModel(
      id: '1',
      userId: 'user1',
      userName: 'John Doe',
      userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      imageUrl: 'https://picsum.photos/800/1000',
      caption: 'Enjoying a beautiful day with family! 😊 #FamilyTime #Happy',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 42,
      comments: [
        CommentModel(
          id: '1',
          userId: 'user2',
          userName: 'Jane Smith',
          userImageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
          text: 'Looks amazing! 😍',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    PostModel(
      id: '2',
      userId: 'user3',
      userName: 'Mike Johnson',
      userImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      imageUrl: 'https://picsum.photos/800/1001',
      caption: 'Family reunion after so long! ❤️ #FamilyFirst',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 28,
      comments: [],
    ),
  ];

  void _viewStory(StoryModel story, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewScreen(
          stories: _stories,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Family Connect',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Stories
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: StoryCircleWidget(
                        story: story,
                        onTap: () => _viewStory(story, index),
                      ),
                    );
                  },
                ),
              ),
              
              // Divider
              const Divider(thickness: 8, height: 8, color: Colors.grey100),
              
              // Posts
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return PostWidget(post: _posts[index]);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 28),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, size: 28),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/1.jpg',
              ),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // TODO: Handle bottom navigation
        },
      ),
    );
  }
}
