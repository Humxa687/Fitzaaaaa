import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _rotationController;
  late AnimationController _beatController;

  @override
  void initState() {
    super.initState();
    // Rotation animation for vinyl album cover
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // Continuous beat pulsing & radial equalizer animation
    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _rotationController.dispose();
    _beatController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildSourceBadge(String? source) {
    Color badgeColor = Colors.blue;
    IconData badgeIcon = Icons.music_note;
    String label = "Web Music";

    switch (source?.toLowerCase()) {
      case 'spotify':
        badgeColor = const Color(0xFF1DB954);
        badgeIcon = Icons.graphic_eq;
        label = "Spotify";
        break;
      case 'apple':
        badgeColor = const Color(0xFFFA243C);
        badgeIcon = Icons.apple;
        label = "Apple Music";
        break;
      case 'youtube':
        badgeColor = const Color(0xFFFF0000);
        badgeIcon = Icons.play_circle_fill;
        label = "YouTube";
        break;
      case 'local':
        badgeColor = Colors.amber;
        badgeIcon = Icons.folder_special;
        label = "Local Track";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 15, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);

    // Synchronize vinyl rotation & beat line animations with playback state
    if (provider.isPlaying) {
      if (!_rotationController.isAnimating) _rotationController.repeat();
      if (!_beatController.isAnimating) _beatController.repeat(reverse: true);
    } else {
      if (_rotationController.isAnimating) _rotationController.stop();
      if (_beatController.isAnimating) _beatController.stop();
    }

    final coverUrl = provider.trackCoverUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Universal Music Player"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              provider.isCurrentTrackFavorite ? Icons.favorite : Icons.favorite_border,
              color: provider.isCurrentTrackFavorite ? Colors.red : null,
            ),
            onPressed: provider.toggleFavoriteTrack,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Blurred background album artwork
          if (coverUrl != null && coverUrl.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Clean Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "FITZA MUSIC PLAYER",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Text(
                            "Audio Playback & Device Media Remote",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: "Import Local File",
                          icon: Icon(Icons.folder_open, color: theme.colorScheme.secondary),
                          onPressed: () => provider.importAndPlayLocalMusic(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Player Mode Selector (Device Media Remote vs Local Audio)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.audiotrack_rounded, size: 16),
                        label: const Text("Audio Player"),
                        selected: !provider.isExternalRemoteMode,
                        onSelected: (val) => provider.setExternalRemoteMode(false),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        avatar: const Icon(Icons.phonelink_ring_rounded, size: 16),
                        label: const Text("External App Remote"),
                        selected: provider.isExternalRemoteMode,
                        onSelected: (val) => provider.setExternalRemoteMode(true),
                      ),
                    ],
                  ),
                ),


                const Spacer(),

                // Center Circular Album Artwork with Radial Beat Lines & Pulse
                AnimatedBuilder(
                  animation: _beatController,
                  builder: (context, child) {
                    final beatValue = provider.isPlaying ? _beatController.value : 0.0;
                    final pulseScale = 1.0 + (beatValue * 0.04);

                    return Transform.scale(
                      scale: pulseScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Radial Beat Lines radiating outward around the circle
                          CustomPaint(
                            size: const Size(320, 320),
                            painter: RadialBeatLinesPainter(
                              isPlaying: provider.isPlaying,
                              beatValue: beatValue,
                              primaryColor: theme.colorScheme.primary,
                              accentColor: Colors.purpleAccent,
                            ),
                          ),

                          // 2. Soft Glowing Backdrop
                          Container(
                            width: 235,
                            height: 235,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (provider.isPlaying ? theme.colorScheme.primary : Colors.purple)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 35 + (beatValue * 15),
                                  spreadRadius: 10 + (beatValue * 5),
                                )
                              ],
                            ),
                          ),

                          // 3. Rotating Vinyl Album Cover Disc
                          RotationTransition(
                            turns: _rotationController,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                border: Border.all(color: Colors.white30, width: 3),
                              ),
                              child: ClipOval(
                                child: coverUrl != null && coverUrl.isNotEmpty
                                    ? Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildFallbackArt(theme),
                                      )
                                    : _buildFallbackArt(theme),
                              ),
                            ),
                          ),

                          // 4. Center Vinyl Pin hole
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.9),
                              border: Border.all(color: Colors.white70, width: 2),
                            ),
                            child: Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Source Platform Badge
                _buildSourceBadge(provider.trackSource),
                const SizedBox(height: 10),

                // Actual Song Title & Artist Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        provider.trackTitle ?? "Select a track",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        provider.isExternalRemoteMode
                            ? "${provider.trackArtist ?? 'Unknown Artist'} • External Session"
                            : (provider.trackArtist ?? "Unknown Artist"),
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Connected Interactive Seekbar Slider (Active in all modes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: theme.colorScheme.primary,
                          inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                          thumbColor: theme.colorScheme.primary,
                        ),
                        child: Slider(
                          min: 0,
                          max: provider.totalDuration.inSeconds > 0
                              ? provider.totalDuration.inSeconds.toDouble()
                              : 1.0,
                          value: provider.currentPosition.inSeconds.toDouble().clamp(
                                0.0,
                                provider.totalDuration.inSeconds > 0
                                    ? provider.totalDuration.inSeconds.toDouble()
                                    : 1.0,
                              ),
                          onChanged: (val) {
                            provider.seekTo(Duration(seconds: val.toInt()));
                          },
                        ),
                      ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(provider.currentPosition), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(_formatDuration(provider.totalDuration), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                // Controls Row
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.loop,
                          color: provider.isLooping ? theme.colorScheme.primary : Colors.grey,
                          size: 26,
                        ),
                        onPressed: provider.toggleLoop,
                      ),
                      if (provider.isPlaying)
                        ...List.generate(2, (index) => _buildPitchBar(theme, index)),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 40),
                        onPressed: provider.prevMusic,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                          onPressed: provider.playPauseMusic,
                        ),
                      ).animate(target: provider.isPlaying ? 1 : 0).scaleXY(begin: 1.0, end: 1.08, duration: 200.ms),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 40),
                        onPressed: provider.nextMusic,
                      ),
                      if (provider.isPlaying)
                        ...List.generate(2, (index) => _buildPitchBar(theme, index + 2)),
                      IconButton(
                        icon: const Icon(Icons.playlist_play_rounded, size: 30),
                        onPressed: () {
                          _showPlaylistBottomSheet(context, provider);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackArt(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, size: 90, color: Colors.white),
      ),
    );
  }

  void _showPlaylistBottomSheet(BuildContext context, FitnessProvider provider) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Up Next Queue", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${provider.playlist.length} tracks",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.playlist.length,
                  itemBuilder: (context, index) {
                    final track = provider.playlist[index];
                    final isPlaying = provider.currentTrackIndex == index;
                    final cover = track["coverUrl"];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: cover != null && cover.isNotEmpty
                              ? Image.network(
                                  cover,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.blue.shade800,
                                    child: const Icon(Icons.music_note, color: Colors.white),
                                  ),
                                )
                              : Container(
                                  color: Colors.blue.shade800,
                                  child: const Icon(Icons.music_note, color: Colors.white),
                                ),
                        ),
                      ),
                      title: Text(
                        track["title"]!,
                        style: TextStyle(
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                          color: isPlaying ? theme.colorScheme.primary : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track["artist"]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isPlaying
                          ? const Icon(Icons.graphic_eq, color: Colors.blue)
                          : null,
                      onTap: () {
                        provider.playTrackAtIndex(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPitchBar(ThemeData theme, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 3,
      height: 12.0 + (index % 3) * 8,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(2),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scaleY(begin: 0.4, end: 1.4, duration: (220 + (index % 3) * 90).ms, curve: Curves.easeInOut);
  }
}

/// CustomPainter that draws 36 radial equalizer beat lines radiating outward around the circle
class RadialBeatLinesPainter extends CustomPainter {
  final bool isPlaying;
  final double beatValue;
  final Color primaryColor;
  final Color accentColor;

  RadialBeatLinesPainter({
    required this.isPlaying,
    required this.beatValue,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 124.0; // Radius aligned with the vinyl album art disc
    const int totalLines = 36;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;


    for (int i = 0; i < totalLines; i++) {
      final angle = (i * 2 * math.pi) / totalLines;
      
      // Calculate dynamic line length based on beat wave calculation
      double length = 8.0;
      if (isPlaying) {
        final wave = math.sin((beatValue * 2 * math.pi) + (i * 0.5)).abs();
        length = 10.0 + (wave * 24.0);
      }

      final startOffset = Offset(
        center.dx + (baseRadius + 4) * math.cos(angle),
        center.dy + (baseRadius + 4) * math.sin(angle),
      );

      final endOffset = Offset(
        center.dx + (baseRadius + 4 + length) * math.cos(angle),
        center.dy + (baseRadius + 4 + length) * math.sin(angle),
      );

      paint.color = Color.lerp(primaryColor, accentColor, (i % 5) / 5.0)!
          .withValues(alpha: isPlaying ? 0.85 : 0.3);
      paint.strokeWidth = isPlaying ? 3.0 : 2.0;

      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RadialBeatLinesPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying || oldDelegate.beatValue != beatValue;
  }
}
