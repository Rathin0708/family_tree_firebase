import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:family_tree_firebase/features/home/domain/models/story_model.dart';

class StoryViewScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late VideoPlayerController? _videoController;
  bool _isPaused = false;
  double _progress = 0.0;
  final Duration _storyDuration = const Duration(seconds: 5);
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadCurrentStory();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _disposeVideoController();
    super.dispose();
  }
  
  void _disposeVideoController() {
    _videoController?.removeListener(_videoListener);
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
  }
  
  void _loadCurrentStory() async {
    _disposeVideoController();
    
    final currentStory = widget.stories[_currentIndex];
    
    if (currentStory.videoUrl != null) {
      _videoController = VideoPlayerController.network(currentStory.videoUrl!)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _videoController?.play();
              _videoController?.addListener(_videoListener);
            });
          }
        });
    } else {
      // For images, start the progress timer
      if (!_isPaused) {
        _startProgressTimer();
      }
    }
    
    setState(() {});
  }
  
  void _videoListener() {
    if (_videoController != null && _videoController!.value.isPlaying) {
      final duration = _videoController!.value.duration;
      final position = _videoController!.value.position;
      
      if (duration.inMilliseconds > 0) {
        setState(() {
          _progress = position.inMilliseconds / duration.inMilliseconds;
        });
      }
      
      // If video ended, go to next story
      if (position >= duration) {
        _nextStory();
      }
    }
  }
  
  void _startProgressTimer() {
    _progress = 0.0;
    final startTime = DateTime.now();
    
    void updateProgress() {
      if (_isPaused || !mounted) return;
      
      final now = DateTime.now();
      final elapsed = now.difference(startTime);
      
      setState(() {
        _progress = elapsed.inMilliseconds / _storyDuration.inMilliseconds;
      });
      
      if (_progress >= 1.0) {
        _nextStory();
      } else {
        Future.delayed(const Duration(milliseconds: 50), updateProgress);
      }
    }
    
    updateProgress();
  }
  
  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }
  
  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }
  
  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _loadCurrentStory();
    }
  }
  
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_videoController != null) {
      if (_isPaused) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
    } else if (!_isPaused) {
      _startProgressTimer();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentStory = widget.stories[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _togglePause(),
        onTapUp: (_) => _togglePause(),
        onTapCancel: _togglePause,
        child: Stack(
          children: [
            // Story content
            PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or Video
                    if (story.imageUrl != null)
                      Image.network(
                        story.imageUrl!,
                        fit: BoxFit.contain,
                      )
                    else if (story.videoUrl != null && _videoController != null)
                      Center(
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                    
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Progress indicators
            Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: List.generate(
                      widget.stories.length,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: LinearProgressIndicator(
                              value: index == _currentIndex
                                  ? _progress
                                  : index < _currentIndex
                                      ? 1.0
                                      : 0.0,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Header with user info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(currentStory.userImageUrl),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentStory.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (currentStory.isLive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Bottom actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Send message',
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white24,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Tap areas for navigation
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.4,
              child: GestureDetector(
                onTap: _previousStory,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.4,
              child: GestureDetector(
                onTap: _nextStory,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            
            // Pause indicator
            if (_isPaused)
              const Center(
                child: Icon(
                  Icons.pause_circle_outline,
                  size: 80,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
