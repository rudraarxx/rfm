import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/controllers/recording_controller.dart';
import '../widgets/glass_container.dart';
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
          // Background Backdrop
          Container(
            decoration: BoxDecoration(
              image: station.favicon != null
                  ? DecorationImage(
                      image: NetworkImage(station.favicon!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.8),
                        BlendMode.darken,
                      ),
                    )
                  : null,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Top Bar
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.chevronDown, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.shieldCheck, color: Color(0xFFD4AF37), size: 10),
                            SizedBox(width: 4),
                            Text(
                              'LOSSLESS',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.settings, size: 24),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const Padding(
                              padding: EdgeInsets.all(20),
                              child: SettingsPanel(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Large Artwork
                  Hero(
                    tag: 'player-art',
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1810),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.15),
                              blurRadius: 60,
                              offset: const Offset(0, 30),
                            ),
                          ],
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

                  const SizedBox(height: 48),

                  // Metadata
                  Column(
                    children: [
                      Text(
                        station.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${station.tags?.split(',').first ?? 'Maharashtra'} • Nagpur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  // Controls & Visualizer
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AudioVisualizer(
                        isPlaying: radioState.isPlaying,
                        style: radioState.visualizerStyle,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 120,
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(radioControllerProvider.notifier).togglePlay();
                        },
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD4AF37).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            radioState.isPlaying ? LucideIcons.pause : LucideIcons.play,
                            color: const Color(0xFFD4AF37),
                            size: 40,
                          ),
                        ),
                      ),
                      
                      // Tape Deck Recording Button
                      Positioned(
                        right: 0,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final recState = ref.watch(recordingControllerProvider);
                            final recNotifier = ref.read(recordingControllerProvider.notifier);
                            
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                if (recState.isRecording) {
                                  recNotifier.stopRecording();
                                } else {
                                  recNotifier.startRecording();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: recState.isRecording 
                                    ? Colors.red.withOpacity(0.15) 
                                    : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: recState.isRecording ? Colors.red : Colors.white10,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (recState.isRecording) ...[
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ).animate(onPlay: (c) => c.repeat()).pulse(duration: 1.seconds),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${recState.duration.inMinutes}:${(recState.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                      ),
                                    ] else 
                                      const Icon(LucideIcons.mic, size: 14, color: Colors.white38),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  const SizedBox(height: 40),

                  // Volume
                  Row(
                    children: [
                      const Icon(LucideIcons.volume1, size: 18, color: Colors.white38),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFFD4AF37),
                            inactiveTrackColor: Colors.white10,
                            thumbColor: Colors.white,
                            overlayColor: const Color(0xFFD4AF37).withOpacity(0.1),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: radioState.volume,
                            onChanged: (v) => ref.read(radioControllerProvider.notifier).setVolume(v),
                          ),
                        ),
                      ),
                      const Icon(LucideIcons.volume2, size: 18, color: Colors.white38),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
