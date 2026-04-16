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
      body: Stack(
        children: [
          // Background - Solid Industrial Surface
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar - Asymmetric
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.chevronDown, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'ANALOG RECEIVER // V.1.0',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.settings, size: 20),
                        onPressed: () {
                          // ... settings logic
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 64),

                  // Large Artwork - Sharp Edges
                  Center(
                    child: Hero(
                      tag: 'player-art',
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                            image: station.favicon != null
                                ? DecorationImage(
                                    image: NetworkImage(station.favicon!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Metadata - Technical Authority
                  Text(
                    station.name.toUpperCase(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LOCATION: ${station.tags?.split(',').first ?? 'MAHARASHTRA'} // STATUS: CONNECTED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      letterSpacing: 1.0,
                    ),
                  ),

                  const Spacer(),

                  // Controls - Forged Elements
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AudioVisualizer(
                        isPlaying: radioState.isPlaying,
                        style: radioState.visualizerStyle,
                        width: MediaQuery.of(context).size.width,
                        height: 160,
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(radioControllerProvider.notifier).togglePlay();
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: RFMTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            radioState.isPlaying ? LucideIcons.pause : LucideIcons.play,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Volume - Machined Slider
                  Row(
                    children: [
                      Icon(LucideIcons.volume1, size: 16, color: Theme.of(context).colorScheme.primary),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
                            inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            thumbColor: Colors.white,
                            trackHeight: 1,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: radioState.volume,
                            onChanged: (v) => ref.read(radioControllerProvider.notifier).setVolume(v),
                          ),
                        ),
                      ),
                      Icon(LucideIcons.volume2, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
