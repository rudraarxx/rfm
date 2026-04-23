import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/providers/sleep_timer_provider.dart';
import '../screens/player_screen.dart';
import '../../core/theme/rfm_theme.dart';
import 'glass_container.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioState = ref.watch(radioControllerProvider);
    final station = radioState.currentStation;

    if (station == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const PlayerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF121212).withOpacity(0.95),
          border: const Border(
            top: BorderSide(color: Colors.white12, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Artwork
            Hero(
              tag: 'player-art',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 44,
                  height: 44,
                  color: RFMTheme.surface,
                  child: station.favicon != null && station.favicon!.isNotEmpty
                      ? Image.network(
                          station.favicon!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white24),
                        )
                      : const Icon(Icons.music_note, color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Metadata
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    station.tags?.split(',').first ?? 'Radio',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            // Sleep Timer Indicator (PRD 3.3 / APP_FLOW)
            Consumer(
              builder: (context, ref, _) {
                final sleepTimer = ref.watch(sleepTimerProvider);
                if (sleepTimer == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: RFMTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${sleepTimer.inMinutes}m',
                        style: const TextStyle(color: RFMTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Controls
            radioState.isBuffering
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      radioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => ref.read(radioControllerProvider.notifier).togglePlay(),
                  ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
              onPressed: radioState.hasNext
                  ? () => ref.read(radioControllerProvider.notifier).skipToNext()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
