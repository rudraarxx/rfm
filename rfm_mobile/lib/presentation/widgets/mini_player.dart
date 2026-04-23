import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/providers/sleep_timer_provider.dart';
import '../screens/player_screen.dart';
import 'glass_container.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioState = ref.watch(radioControllerProvider);
    final sleepTimer = ref.watch(sleepTimerProvider);
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
      child: GlassContainer(
        borderRadius: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.9),
        child: Row(
          children: [
            // Artwork
            Hero(
              tag: 'player-art',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  image: station.favicon != null
                      ? DecorationImage(
                          image: NetworkImage(station.favicon!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: station.favicon == null
                    ? Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary, size: 24)
                    : null,
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
                    station.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: radioState.isPlaying 
                              ? Theme.of(context).colorScheme.primaryContainer 
                              : Colors.white24,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ANALYZING FREQUENCY...',
                        style: TextStyle(
                          fontSize: 8,
                          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sleep timer badge
            if (sleepTimer != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 3),
                    Text(
                      '${sleepTimer.inMinutes}:${(sleepTimer.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

            // Controls
            radioState.isBuffering
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      radioState.isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    onPressed: () => ref.read(radioControllerProvider.notifier).togglePlay(),
                  ),
          ],
        ),
      ),
    );
  }
}
