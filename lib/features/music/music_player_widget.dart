import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import '../dashboard/music_player_screen.dart';

class MusicPlayerWidget extends StatelessWidget {
  const MusicPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicPlayerScreen()));
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            height: 76,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator line
                Container(
                  height: 3,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white12 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: provider.totalDuration.inSeconds > 0 ? (provider.currentPosition.inSeconds / provider.totalDuration.inSeconds).clamp(0.0, 1.0) : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Track cover / Art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: FitzaTheme.orangeGradient,
                        ),
                        child: provider.trackCoverUrl != null && provider.trackCoverUrl!.isNotEmpty
                            ? Image.network(
                                provider.trackCoverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              )
                            : const Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Track Name & Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.trackTitle ?? "Unknown Track",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            provider.trackArtist ?? "Unknown Artist",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (provider.isLooping)
                            Text(
                              "Looping",
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                    // Player Controls
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: () => provider.prevMusic(),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary,
                      child: IconButton(
                        icon: Icon(
                          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => provider.playPauseMusic(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: () => provider.nextMusic(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
