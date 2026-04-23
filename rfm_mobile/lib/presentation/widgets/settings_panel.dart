import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/providers/sleep_timer_provider.dart';
import '../../core/theme/rfm_theme.dart';
import 'glass_container.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioState = ref.watch(radioControllerProvider);
    final notifier = ref.read(radioControllerProvider.notifier);
    final sleepTimer = ref.watch(sleepTimerProvider);
    final sleepNotifier = ref.read(sleepTimerProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 24, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Visualizer Style (PRD requirement 3.3)
          const Text(
            'Visualizer Mode',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StyleButton(
                label: 'Classic',
                isActive: radioState.visualizerStyle == 'classic',
                onTap: () => notifier.setVisualizerStyle('classic'),
              ),
              const SizedBox(width: 12),
              _StyleButton(
                label: 'Colorful',
                isActive: radioState.visualizerStyle == 'colorful',
                onTap: () => notifier.setVisualizerStyle('colorful'),
              ),
            ],
          ),
          
          const SizedBox(height: 30),

          // Sleep Timer (Backlog item 74 - PRD)
          const Text(
            'Sleep Timer',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TimerButton(
                label: 'Off',
                isActive: sleepTimer == null,
                onTap: () => sleepNotifier.cancel(),
              ),
              const SizedBox(width: 8),
              _TimerButton(
                label: '15m',
                isActive: sleepTimer != null && sleepTimer.inMinutes == 15,
                onTap: () => sleepNotifier.set(const Duration(minutes: 15)),
              ),
              const SizedBox(width: 8),
              _TimerButton(
                label: '30m',
                isActive: sleepTimer != null && sleepTimer.inMinutes == 30,
                onTap: () => sleepNotifier.set(const Duration(minutes: 30)),
              ),
              const SizedBox(width: 8),
              _TimerButton(
                label: '60m',
                isActive: sleepTimer != null && sleepTimer.inMinutes == 60,
                onTap: () => sleepNotifier.set(const Duration(minutes: 60)),
              ),
            ],
          ),
          if (sleepTimer != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Stopping in ${sleepTimer.inMinutes}:${(sleepTimer.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: RFMTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Audio Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.high_quality_rounded, color: RFMTheme.primary, size: 20),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HQ Streaming Active',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '320kbps • SSL Secured',
                      style: TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _StyleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TimerButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
