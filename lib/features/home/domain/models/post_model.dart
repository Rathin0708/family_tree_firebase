class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String imageUrl;
  final String caption;
  final DateTime timestamp;
  final int likes;
  final List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
    this.likes = 0,
    this.comments = const [],
  });

  // Helper method to format the time since the post was created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
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

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.text,
    required this.timestamp,
  });

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
