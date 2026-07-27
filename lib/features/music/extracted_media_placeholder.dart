import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import '../dashboard/music_player_screen.dart';

class ExtractedMediaPlaceholderWidget extends StatefulWidget {
  const ExtractedMediaPlaceholderWidget({super.key});

  @override
  State<ExtractedMediaPlaceholderWidget> createState() => _ExtractedMediaPlaceholderWidgetState();
}

class _ExtractedMediaPlaceholderWidgetState extends State<ExtractedMediaPlaceholderWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _beatController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _beatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FitnessProvider>(context);

    // Sync animation state with extracted playback state
    if (provider.isPlaying) {
      if (!_rotationController.isAnimating) _rotationController.repeat();
      if (!_beatController.isAnimating) _beatController.repeat(reverse: true);
    } else {
      if (_rotationController.isAnimating) _rotationController.stop();
      if (_beatController.isAnimating) _beatController.stop();
    }

    final isAudioActive = provider.isPlaying;
    final coverUrl = provider.trackCoverUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isAudioActive
              ? FitzaTheme.energyOrange.withValues(alpha: 0.5)
              : theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAudioActive
                ? FitzaTheme.energyOrange.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isAudioActive
                  ? FitzaTheme.energyOrange.withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isAudioActive ? Icons.graphic_eq_rounded : Icons.cell_tower_rounded,
                      color: isAudioActive ? FitzaTheme.energyOrange : theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAudioActive
                          ? "Extracted Background Media Active"
                          : "Background Media Extractor",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isAudioActive ? FitzaTheme.energyOrange : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isAudioActive ? Colors.green : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isAudioActive ? "LIVE" : "IDLE",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Animated Vinyl Disc & Artwork Placeholder
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicPlayerScreen()));
                  },
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * 2 * math.pi,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: isAudioActive
                                    ? FitzaTheme.energyOrange.withValues(alpha: 0.4)
                                    : Colors.black26,
                                blurRadius: 12,
                              ),
                            ],
                            border: Border.all(
                              color: isAudioActive ? FitzaTheme.energyOrange : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: coverUrl != null && coverUrl.isNotEmpty
                                    ? Image.network(
                                        coverUrl,
                                        width: 76,
                                        height: 76,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildFallbackDisk(theme),
                                      )
                                    : _buildFallbackDisk(theme),
                              ),
                              // Vinyl Center Ring
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.85),
                                  border: Border.all(color: Colors.white70, width: 1.5),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Extracted Track Details & Equalizer Bars
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.trackTitle ?? "Extracting background media...",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.trackArtist ?? "Play Spotify / Apple Music / YouTube",
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),

                      // Animated Equalizer Visualizer Bars
                      AnimatedBuilder(
                        animation: _beatController,
                        builder: (context, child) {
                          final p = _beatController.value;
                          return Row(
                            children: List.generate(8, (index) {
                              final height = isAudioActive
                                  ? (8.0 + (math.sin(p * math.pi + index) * 12.0).abs())
                                  : 4.0;
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 4,
                                height: height,
                                decoration: BoxDecoration(
                                  color: isAudioActive
                                      ? FitzaTheme.energyOrange
                                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Control Row linked directly to background media keys
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: 28,
                  onPressed: () => provider.prevMusic(),
                ),
                IconButton(
                  icon: Icon(
                    isAudioActive ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: isAudioActive ? FitzaTheme.energyOrange : theme.colorScheme.primary,
                  ),
                  iconSize: 44,
                  onPressed: () => provider.playPauseMusic(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: 28,
                  onPressed: () => provider.nextMusic(),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_full_rounded, size: 20),
                  tooltip: "Open Full Extractor Remote",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicPlayerScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFallbackDisk(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: FitzaTheme.orangeGradient,
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
