import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/models/friction_moment.dart';
import '../../../core/utils/constants.dart';
import '../../../providers/friction_providers.dart';

class FrictionScreen extends ConsumerStatefulWidget {
  final FrictionMoment moment;

  const FrictionScreen({
    super.key,
    required this.moment,
  });

  @override
  ConsumerState<FrictionScreen> createState() => _FrictionScreenState();
}

class _FrictionScreenState extends ConsumerState<FrictionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _canDismiss = false;
  late DateTime _startTime;
  String? _selectedEmotion;
  bool _showEmotionSelection = false;

  // Common emotions for tracking
  final List<Map<String, dynamic>> _emotions = [
    {'label': 'Bored', 'icon': Icons.sentiment_neutral},
    {'label': 'Anxious', 'icon': Icons.sentiment_very_dissatisfied},
    {'label': 'Curious', 'icon': Icons.psychology},
    {'label': 'Avoiding', 'icon': Icons.run_circle_outlined},
    {'label': 'Lonely', 'icon': Icons.person_outline},
    {'label': 'Tired', 'icon': Icons.bedtime},
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Enable dismiss after minimum wait time
    Timer(
      Duration(seconds: AppConstants.minimumFrictionDurationSeconds),
      () {
        if (mounted) {
          setState(() => _canDismiss = true);
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleChoice(UserChoice choice) async {
    // Phase 2: Ask for emotion before final choice
    if (!_showEmotionSelection && widget.moment.mode == FrictionMode.question) {
      setState(() {
        _showEmotionSelection = true;
      });
      return;
    }

    final duration = DateTime.now().difference(_startTime);

    final updatedMoment = widget.moment.copyWith(
      choice: choice,
      emotionalState: _selectedEmotion,
      displayDurationMs: duration.inMilliseconds,
    );

    final storage = ref.read(storageServiceProvider);
    await storage.updateFrictionMoment(updatedMoment);

    if (mounted) {
      Navigator.of(context).pop(choice);
    }
  }

  void _selectEmotion(String emotion) {
    setState(() {
      _selectedEmotion = emotion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canDismiss,
      onPopInvoked: (didPop) {
        if (didPop && _canDismiss) {
          _handleChoice(UserChoice.dismissed);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(AppConstants.backgroundColorValue),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Breathing animation circle
                    _buildBreathingCircle(),

                    const SizedBox(height: 60),

                    // Prompt text
                    Text(
                      widget.moment.prompt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.5,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Emotion selection (Phase 2)
                    if (_canDismiss && _showEmotionSelection) ...[
                      Text(
                        'How are you feeling?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEmotionGrid(),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedEmotion = null;
                            _showEmotionSelection = false;
                          });
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ]
                    // Action buttons
                    else if (_canDismiss) ...[
                      _buildActionButton(
                        label: 'Proceed Anyway',
                        onPressed: () => _handleChoice(UserChoice.proceeded),
                        isPrimary: false,
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        label: 'Close',
                        onPressed: () => _handleChoice(UserChoice.closed),
                        isPrimary: true,
                      ),
                    ] else ...[
                      // Wait indicator
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(
                          seconds: AppConstants.minimumFrictionDurationSeconds,
                        ),
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(AppConstants.primaryColorValue),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Take a moment to reflect...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingCircle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(AppConstants.primaryColorValue).withOpacity(0.6),
                  const Color(AppConstants.primaryColorValue).withOpacity(0.1),
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation in reverse for breathing effect
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(AppConstants.primaryColorValue)
              : Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Colors.white24),
          ),
          elevation: isPrimary ? 4 : 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _emotions.map((emotion) {
        final isSelected = _selectedEmotion == emotion['label'];
        return InkWell(
          onTap: () {
            _selectEmotion(emotion['label'] as String);
            // Auto-proceed after selecting emotion
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _showEmotionSelection = false;
                });
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(AppConstants.primaryColorValue).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(AppConstants.primaryColorValue)
                    : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  emotion['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  emotion['label'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
