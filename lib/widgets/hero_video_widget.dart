import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class HeroVideoWidget extends StatefulWidget {
  final String videoPath;
  final double height;
  final Widget? overlay;

  const HeroVideoWidget({
    Key? key,
    required this.videoPath,
    this.height = 200,
    this.overlay,
  }) : super(key: key);

  @override
  State<HeroVideoWidget> createState() => _HeroVideoWidgetState();
}

class _HeroVideoWidgetState extends State<HeroVideoWidget> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isLoading = true;
  Timer? _retryTimer;
  bool _wasPlayingBeforePause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay initialization to ensure the widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    
    // Cancel any existing retry timer
    _retryTimer?.cancel();
    _retryTimer = null;
    
    try {
      debugPrint('🎥 Initializing video: ${widget.videoPath}');
      
      // Clean up any existing controller first
      if (_controller != null) {
        try {
          _controller!.removeListener(_videoListener);
          await _controller!.dispose();
        } catch (e) {
          debugPrint('🎥 Error disposing previous controller: $e');
        }
        _controller = null;
      }
      
      // Test if asset exists first
      try {
        final assetBundle = DefaultAssetBundle.of(context);
        await assetBundle.load(widget.videoPath);
        debugPrint('🎥 ✅ Video asset found and loaded');
      } catch (assetError) {
        debugPrint('🎥 ❌ Video asset not found: $assetError');
        throw Exception('Video asset not found: ${widget.videoPath}');
      }
      
      // Create controller with optimized settings
      _controller = VideoPlayerController.asset(
        widget.videoPath,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );
      
      if (!mounted) return;
      
      // Add listener for errors and state changes
      _controller!.addListener(_videoListener);
      
      debugPrint('🎥 Starting video initialization...');
      
      // Initialize with timeout
      await _controller!.initialize().timeout(
        const Duration(seconds: 15), // Increased timeout
        onTimeout: () {
          throw TimeoutException('Video initialization timeout', const Duration(seconds: 15));
        },
      );
      
      if (!mounted) return;
      
      debugPrint('🎥 Video controller initialized successfully');
      
      if (_controller!.value.isInitialized) {
        debugPrint('🎥 Video is initialized and ready to play');
        debugPrint('🎥 Video size: ${_controller!.value.size}');
        debugPrint('🎥 Video duration: ${_controller!.value.duration}');
        
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isLoading = false;
            _hasError = false;
          });
        }
        
        // Configure video playback
        try {
          await _controller!.setLooping(true);
          await _controller!.setVolume(0.0);
          
          // Add a delay before playing
          await Future.delayed(const Duration(milliseconds: 200));
          
          if (mounted && _controller != null && _controller!.value.isInitialized) {
            await _controller!.play();
            debugPrint('🎥 ✅ Video is now playing successfully!');
          }
        } catch (playError) {
          debugPrint('🎥 ❌ Error starting video playback: $playError');
          // Don't treat playback errors as fatal
        }
      } else {
        debugPrint('🎥 ❌ Video controller not properly initialized');
        throw Exception('Video controller initialization failed');
      }
    } catch (e) {
      debugPrint('🎥 ❌ Error initializing video: $e');
      debugPrint('🎥 Error type: ${e.runtimeType}');
      
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller == null || !mounted) return;
    
    final value = _controller!.value;
    
    // Handle errors
    if (value.hasError) {
      debugPrint('🎥 ❌ Video player error: ${value.errorDescription}');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        
        // Try to recover from error after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _hasError) {
            debugPrint('🎥 Attempting to recover from error...');
            _retryInitialization();
          }
        });
      }
      return;
    }
    
    // Handle initialization state changes
    if (value.isInitialized && !_isInitialized) {
      debugPrint('🎥 Video became initialized');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _hasError = false;
        });
      }
    }
    
    // Handle buffering state
    if (value.isBuffering && _isInitialized) {
      // Video is buffering, this is normal
    }
  }

  Future<void> _retryInitialization() async {
    if (!mounted) return;
    
    debugPrint('🎥 🔄 Retrying video initialization...');
    
    // Clean up previous controller
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      await _controller!.dispose();
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isInitialized = false;
    });
    
    // Wait a bit before retrying
    await Future.delayed(const Duration(milliseconds: 1000));
    
    await _initializeVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('🎥 App lifecycle state changed to: $state');
    
    if (_controller == null) return;
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        debugPrint('🎥 App going to background - pausing video');
        // Store the playing state before pausing
        _wasPlayingBeforePause = _controller!.value.isPlaying;
        if (_wasPlayingBeforePause && _isInitialized) {
          try {
            _controller!.pause();
          } catch (e) {
            debugPrint('🎥 Error pausing video: $e');
          }
        }
        break;
      case AppLifecycleState.resumed:
        debugPrint('🎥 App resumed - attempting to resume video');
        // Add a delay to ensure the app is fully resumed
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _controller != null && _isInitialized) {
            try {
              // Check if controller is still valid and initialized
              if (_controller!.value.isInitialized) {
                if (_wasPlayingBeforePause) {
                  debugPrint('🎥 Resuming video playback');
                  _controller!.play();
                }
              } else {
                // Controller lost initialization, reinitialize
                debugPrint('🎥 Controller lost initialization, reinitializing...');
                _reinitializeAfterResume();
              }
            } catch (e) {
              debugPrint('🎥 Error resuming video: $e');
              // If resume fails, try to reinitialize
              _reinitializeAfterResume();
            }
          }
        });
        break;
      case AppLifecycleState.hidden:
        debugPrint('🎥 App hidden');
        break;
    }
  }

  Future<void> _reinitializeAfterResume() async {
    if (!mounted) return;
    
    debugPrint('🎥 Reinitializing video after app resume...');
    
    // Clean up current controller
    try {
      if (_controller != null) {
        _controller!.removeListener(_videoListener);
        await _controller!.dispose();
      }
    } catch (e) {
      debugPrint('🎥 Error disposing controller during reinit: $e');
    }
    
    // Reset state
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _isLoading = true;
      _controller = null;
    });
    
    // Wait a bit then reinitialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      await _initializeVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retryTimer?.cancel();
    
    try {
      if (_controller != null) {
        _controller!.removeListener(_videoListener);
        _controller!.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing video controller: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0), // Remove border radius
        boxShadow: [
          // Subtle shadow for depth without being too prominent
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6958CA).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0), // Remove border radius
        child: Stack(
          children: [
            // Video player with improved aspect ratio handling
            if (_isInitialized && !_hasError && _controller != null)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final videoAspectRatio = _controller!.value.aspectRatio;
                    final containerAspectRatio = constraints.maxWidth / constraints.maxHeight;
                    
                    // Calculate scale to fill container width while maintaining aspect
                    double scaleX = 1.0;
                    double scaleY = 1.0;
                    
                    if (videoAspectRatio < containerAspectRatio) {
                      // Video is taller than container, stretch horizontally
                      scaleX = containerAspectRatio / videoAspectRatio;
                    } else {
                      // Video is wider than container, might need vertical adjustment
                      scaleY = videoAspectRatio / containerAspectRatio;
                    }
                    
                    return Transform.scale(
                      scaleX: scaleX,
                      scaleY: scaleY,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: videoAspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    );
                  },
                ),
              )
            else if (_hasError)
              // Enhanced animated fallback background
              AnimatedGradientBackground(height: widget.height)
            else if (_isLoading)
              Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6958CA),
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              // Default animated fallback
              AnimatedGradientBackground(height: widget.height),
            
            // Multi-layer gradient overlay for sophisticated blending
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Side gradient for edge blending
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.15, 0.85, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            
            // Subtle color overlay to match app theme
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6958CA).withOpacity(0.1),
                    Colors.transparent,
                    const Color(0xFFFFD700).withOpacity(0.05),
                  ],
                ),
              ),
            ),
            
            // Custom overlay content
            if (widget.overlay != null)
              Positioned.fill(
                child: widget.overlay!,
              ),
          ],
        ),
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final double height;

  const AnimatedGradientBackground({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main gradient animation
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Pulse animation for the icon
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (_animation.value * 0.2),
                0.7 + (_animation.value * 0.2),
                1.0,
              ],
              colors: [
                Color.lerp(
                  const Color(0xFF6958CA).withOpacity(0.8),
                  const Color(0xFFFFD700).withOpacity(0.6),
                  _animation.value,
                )!,
                Color.lerp(
                  const Color(0xFFFFD700).withOpacity(0.6),
                  const Color(0xFF6958CA).withOpacity(0.8),
                  _animation.value,
                )!,
                Color.lerp(
                  Colors.black.withOpacity(0.7),
                  const Color(0xFF6958CA).withOpacity(0.4),
                  _animation.value * 0.5,
                )!,
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white.withOpacity(0.9),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LIVE THE VIBE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}