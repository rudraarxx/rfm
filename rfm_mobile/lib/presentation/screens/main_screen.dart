import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/theme/rfm_theme.dart';
import 'dashboard_screen.dart';
import 'search_screen.dart';
import 'player_screen.dart';
import '../widgets/mini_player.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/providers/history_provider.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final radioState = ref.watch(radioControllerProvider);

    ref.listen<RadioState>(radioControllerProvider, (previous, next) {
      if (next.currentStation != null &&
          next.currentStation?.changeuuid != previous?.currentStation?.changeuuid) {
        ref.read(historyProvider.notifier).add(next.currentStation!);
      }
    });

    final List<Widget> screens = [
      const DashboardScreen(),
      const PlayerScreen(),
      const SearchScreen(),
    ];

    return Scaffold(
      backgroundColor: RFMTheme.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),

          // Mini Player (Universal Layer)
          if (radioState.currentStation != null && currentIndex != 1) // Hide on PlayerScreen
            Positioned(
              left: 0,
              right: 0,
              bottom: 90,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: RFMTheme.surfaceContainerHigh.withOpacity(0.8),
                    child: const MiniPlayer(),
                  ),
                ),
              ),
            ),

          // Glassmorphism Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: RFMTheme.surfaceContainerLowest.withOpacity(0.7),
                    border: Border(
                      top: BorderSide(
                        color: RFMTheme.outline.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(context, ref, Icons.equalizer_rounded, 'FORGE', 0, currentIndex == 0),
                      _buildNavItem(context, ref, Icons.waves_rounded, 'WAVES', 1, currentIndex == 1),
                      _buildNavItem(context, ref, Icons.search_rounded, 'SCAN', 2, currentIndex == 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, IconData icon, String label, int index, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(navigationIndexProvider.notifier).state = index,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? RFMTheme.primaryContainer.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.zero, // Sharp corners
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isActive ? RFMTheme.primaryContainer : RFMTheme.onSurface.withOpacity(0.4),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isActive ? RFMTheme.primaryContainer : RFMTheme.onSurface.withOpacity(0.3),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
