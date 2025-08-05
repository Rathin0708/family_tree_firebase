import 'package:flutter/material.dart';
import 'package:family_tree_firebase/features/home/domain/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends StatefulWidget {
  final PostModel post;

  const PostWidget({
    super.key,
    required this.post,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _showFullCaption = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize timeago
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  void _toggleCaption() {
    setState(() {
      _showFullCaption = !_showFullCaption;
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    // TODO: Implement add comment
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with user info and options
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.post.userImageUrl),
              ),
              
              const SizedBox(width: 12),
              
              // Username
              Text(
                widget.post.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const Spacer(),
              
              // Options button
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Show post options
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        
        // Post image
        AspectRatio(
          aspectRatio: 1.0,
          child: Image.network(
            widget.post.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Like button
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : null,
                  size: 28,
                ),
                onPressed: _toggleLike,
              ),
              
              // Comment button
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 26),
                onPressed: () {
                  // TODO: Focus comment field
                },
              ),
              
              // Share button
              IconButton(
                icon: const Icon(Icons.send_outlined, size: 26),
                onPressed: () {
                  // TODO: Implement share
                },
              ),
              
              const Spacer(),
              
              // Bookmark button
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 28,
                ),
                onPressed: _toggleBookmark,
              ),
            ],
          ),
        ),
        
        // Likes count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${widget.post.likes + (_isLiked ? 1 : 0)} likes',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: GestureDetector(
            onTap: _toggleCaption,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.post.userName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _showFullCaption 
                        ? widget.post.caption 
                        : '${widget.post.caption.substring(0, widget.post.caption.length > 100 ? 100 : widget.post.caption.length)}${widget.post.caption.length > 100 ? '...' : ''}',
                  ),
                  if (widget.post.caption.length > 100) ...[
                    TextSpan(
                      text: _showFullCaption ? ' less' : ' more',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // View all comments
        if (widget.post.comments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'View all ${widget.post.comments.length} comments',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
        
        // Time ago
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            timeago.format(widget.post.timestamp, locale: 'en'),
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 12,
            ),
          ),
        ),
        
        // Add comment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/1.jpg', // Current user's avatar
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Comment input
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addComment(),
                ),
              ),
              
              // Post button
              TextButton(
                onPressed: _addComment,
                child: const Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
