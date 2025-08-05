class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String? imageUrl;
  final String? videoUrl;
  final bool isLive;
  final bool isSeen;
  final DateTime timestamp;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    this.imageUrl,
    this.videoUrl,
    this.isLive = false,
    this.isSeen = false,
    required this.timestamp,
  }) : assert(imageUrl != null || videoUrl != null, 'Either imageUrl or videoUrl must be provided');

  // Helper method to format the time since the story was posted
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}
