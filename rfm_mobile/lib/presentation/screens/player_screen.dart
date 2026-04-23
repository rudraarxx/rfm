import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../core/theme/rfm_theme.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/settings_panel.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioState = ref.watch(radioControllerProvider);
    final station = radioState.currentStation;

    if (station == null) return const Scaffold();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF212121),
              Colors.black.withOpacity(0.9),
              Colors.black,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Radio Station',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 24, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => const SettingsPanel(),
                        );
                      },
                    ),
                  ],
                ),

                const Spacer(),

                // Large Artwork - Rounded
                Center(
                  child: Hero(
                    tag: 'player-art',
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                        image: station.favicon != null && station.favicon!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(station.favicon!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: station.favicon == null || station.favicon!.isEmpty
                          ? const Center(
                              child: Icon(Icons.radio_rounded, color: Colors.white10, size: 120),
                            )
                          : null,
                    ),
                  ),
                ),

                const Spacer(),

                // Metadata
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            station.tags?.split(',').first ?? 'Live Radio',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white60,
                                  fontSize: 18,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border_rounded, size: 28, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                const Spacer(),

                // Live Progress Bar (PRD 3.3 / 6.3 gap)
                Column(
                  children: [
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: radioState.isPlaying ? 1.0 : 0.0, // Indeterminate "Live" feel
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LIVE', style: TextStyle(color: RFMTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        Text('RADIO', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shuffle_rounded, color: Colors.white54),
                    ),
                    IconButton(
                      onPressed: radioState.hasPrevious
                          ? () => ref.read(radioControllerProvider.notifier).skipToPrevious()
                          : null,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        size: 48,
                        color: radioState.hasPrevious ? Colors.white : Colors.white24,
                      ),
                    ),
                    // Play/Pause
                    GestureDetector(
                      onTap: () => ref.read(radioControllerProvider.notifier).togglePlay(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: radioState.isBuffering
                               ? const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                                )
                              : Icon(
                                  radioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 40,
                                ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: radioState.hasNext
                          ? () => ref.read(radioControllerProvider.notifier).skipToNext()
                          : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        size: 48,
                        color: radioState.hasNext ? Colors.white : Colors.white24,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.repeat_rounded, color: Colors.white54),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Volume Slider (PRD 3.3)
                Row(
                  children: [
                    const Icon(Icons.volume_mute_rounded, size: 20, color: Colors.white38),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: radioState.volume,
                          onChanged: (val) => ref.read(radioControllerProvider.notifier).setVolume(val),
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, size: 20, color: Colors.white38),
                  ],
                ),

                const Spacer(),

                // Bottom Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('UP NEXT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.white70)),
                    const Text('RECORDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.white24)),
                    const Text('LYRICS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
