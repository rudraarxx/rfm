import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/controllers/sleep_timer_controller.dart';
import 'glass_container.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioState = ref.watch(radioControllerProvider);
    final notifier = ref.read(radioControllerProvider.notifier);

    return GlassContainer(
      borderRadius: 40,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Color(0xFFD4AF37),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Visualizer Toggle
          const Text(
            'Visualizer Style',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  _StyleButton(
                    label: 'Classic',
                    isActive: radioState.visualizerStyle == 'classic',
                    onTap: () => notifier.setVisualizerStyle('classic'),
                  ),
                  const SizedBox(width: 12),
                  _StyleButton(
                    label: 'Radial',
                    isActive: radioState.visualizerStyle == 'radial',
                    onTap: () => notifier.setVisualizerStyle('radial'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StyleButton(
                    label: 'Waveform',
                    isActive: radioState.visualizerStyle == 'wave',
                    onTap: () => notifier.setVisualizerStyle('wave'),
                  ),
                  const SizedBox(width: 12),
                  _StyleButton(
                    label: 'Dot Matrix',
                    isActive: radioState.visualizerStyle == 'dots',
                    onTap: () => notifier.setVisualizerStyle('dots'),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Sleep Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sleep Timer',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final timerState = ref.watch(sleepTimerControllerProvider);
                  if (!timerState.isActive) return const SizedBox.shrink();
                  return Text(
                    timerState.formattedTime,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final timerState = ref.watch(sleepTimerControllerProvider);
              final timerNotifier = ref.read(sleepTimerControllerProvider.notifier);
              
              if (timerState.isActive) {
                return ElevatedButton(
                  onPressed: () => timerNotifier.cancelTimer(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Center(child: Text('CANCEL TIMER')),
                );
              }

              return Row(
                children: [
                  _TimerButton(label: '15m', onTap: () => timerNotifier.setTimer(15)),
                  const SizedBox(width: 8),
                  _TimerButton(label: '30m', onTap: () => timerNotifier.setTimer(30)),
                  const SizedBox(width: 8),
                  _TimerButton(label: '45m', onTap: () => timerNotifier.setTimer(45)),
                  const SizedBox(width: 8),
                  _TimerButton(label: '60m', onTap: () => timerNotifier.setTimer(60)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          // Audio Info (Static)
          const GlassContainer(
            borderRadius: 20,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(LucideIcons.shieldCheck, color: Color(0xFFD4AF37), size: 20),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lossless Engine Active',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '320kbps • 48kHz',
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
            color: isActive ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.white10,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? const Color(0xFFD4AF37) : Colors.white60,
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
  final VoidCallback onTap;

  const _TimerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
          ),
        ),
      ),
    );
  }
}
