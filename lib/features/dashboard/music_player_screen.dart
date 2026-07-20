import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Now Playing"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Album Art
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 10)
                  ],
                  gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
                ),
                child: const Icon(Icons.music_note, size: 100, color: Colors.white),
              )
                  .animate(target: provider.isPlaying ? 1 : 0)
                  .scaleXY(begin: 0.9, end: 1.0, duration: 400.ms, curve: Curves.easeOut),
              
              const SizedBox(height: 40),
              
              // Title and Artist
              Text(
                provider.trackTitle ?? "Workout Mix",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                provider.trackArtist ?? "Fitza Radio",
                style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              
              const SizedBox(height: 30),
              
              // Progress Bar (Seek)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: theme.colorScheme.primary,
                        inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        thumbColor: theme.colorScheme.primary,
                      ),
                      child: Slider(
                        min: 0,
                        max: provider.totalDuration.inSeconds > 0 ? provider.totalDuration.inSeconds.toDouble() : 1.0,
                        value: provider.currentPosition.inSeconds.toDouble().clamp(
                            0.0, provider.totalDuration.inSeconds > 0 ? provider.totalDuration.inSeconds.toDouble() : 1.0),
                        onChanged: (val) {
                          provider.seekTo(Duration(seconds: val.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(provider.currentPosition), style: const TextStyle(fontSize: 12)),
                          Text(_formatDuration(provider.totalDuration), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.loop, color: provider.isLooping ? theme.colorScheme.primary : Colors.grey, size: 28),
                    onPressed: provider.toggleLoop,
                  ),
                  if (provider.isPlaying)
                    ...List.generate(3, (index) => _buildPitchBar(theme, index)),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 36),
                    onPressed: provider.prevMusic,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                    child: IconButton(
                      icon: Icon(provider.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                      onPressed: provider.playPauseMusic,
                    ),
                  ).animate(target: provider.isPlaying ? 1 : 0).scaleXY(begin: 1.0, end: 1.1, duration: 200.ms),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 36),
                    onPressed: provider.nextMusic,
                  ),
                  if (provider.isPlaying)
                    ...List.generate(3, (index) => _buildPitchBar(theme, index + 3)),
                  IconButton(
                    icon: const Icon(Icons.playlist_play, size: 28),
                    onPressed: () {
                      _showPlaylistBottomSheet(context, provider);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaylistBottomSheet(BuildContext context, FitnessProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Up Next", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.playlist.length,
                  itemBuilder: (context, index) {
                    final track = provider.playlist[index];
                    final isPlaying = provider.currentTrackIndex == index;
                    return ListTile(
                      leading: Icon(isPlaying ? Icons.bar_chart : Icons.music_note, color: isPlaying ? Colors.blue : Colors.grey),
                      title: Text(track["title"]!, style: TextStyle(fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text(track["artist"]!),
                      trailing: isPlaying ? const Icon(Icons.play_circle, color: Colors.blue) : null,
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
      width: 4,
      height: 10.0 + (index % 3) * 8,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scaleY(begin: 0.5, end: 1.5, duration: (200 + (index % 3) * 100).ms, curve: Curves.easeInOutSine);
  }
}
