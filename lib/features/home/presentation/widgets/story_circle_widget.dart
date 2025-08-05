import 'package:flutter/material.dart';
import 'package:family_tree_firebase/features/home/domain/models/story_model.dart';

class StoryCircleWidget extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final double size;

  const StoryCircleWidget({
    super.key,
    required this.story,
    required this.onTap,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Story border with gradient if not seen
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.isSeen
                  ? null
                  : LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.orange,
                        Colors.purple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: Border.all(
                color: story.isSeen ? Colors.grey : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Profile image
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2.5,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(story.userImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Live indicator
                if (story.isLive) ...[
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Username
          SizedBox(
            width: size,
            child: Text(
              story.userName.split(' ')[0], // First name only
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
