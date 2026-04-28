import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/audio/visualizer_service.dart';

class AudioVisualizer extends ConsumerWidget {
  final bool isPlaying;
  final String style;
  final double width;
  final double height;
  final Color? color;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.style = 'classic',
    this.width = 300,
    this.height = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spectrum = ref.watch(spectrumProvider).value ?? List.generate(30, (_) => 0.05);

    return CustomPaint(
      size: Size(width, height),
      painter: VisualizerPainter(
        isPlaying: isPlaying,
        style: style,
        progress: 0, // No longer needed for animation controller
        amplitudes: spectrum,
        color: color ?? const Color(0xFFD4AF37),
      ),
    );
  }
}

class VisualizerPainter extends CustomPainter {
  final bool isPlaying;
  final String style;
  final double progress;
  final List<double> amplitudes;
  final Color color;

  VisualizerPainter({
    required this.isPlaying,
    required this.style,
    required this.progress,
    required this.amplitudes,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (style == 'classic') {
      _paintClassic(canvas, size);
    } else {
      _paintColorful(canvas, size);
    }
  }

  void _paintClassic(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (amplitudes.length * 1.5);
    final gap = barWidth * 0.5;

    for (var i = 0; i < amplitudes.length; i++) {
      final barHeight = size.height * amplitudes[i];
      final x = i * (barWidth + gap) + (size.width - (amplitudes.length * (barWidth + gap))) / 2;
      
      canvas.drawLine(
        Offset(x, size.height / 2 - barHeight / 2),
        Offset(x, size.height / 2 + barHeight / 2),
        paint,
      );
    }
  }

  void _paintColorful(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (amplitudes.length * 1.5);
    final gap = barWidth * 0.5;

    for (var i = 0; i < amplitudes.length; i++) {
      final barHeight = size.height * amplitudes[i];
      final x = i * (barWidth + gap) + (size.width - (amplitudes.length * (barWidth + gap))) / 2;
      
      // Gradient effect
      paint.color = Color.lerp(
        color, 
        const Color(0xFF2C1810), 
        (i / amplitudes.length) * 0.5
      )!.withOpacity(0.8);

      canvas.drawLine(
        Offset(x, size.height / 2 - barHeight / 2),
        Offset(x, size.height / 2 + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VisualizerPainter oldDelegate) {
    return isPlaying || oldDelegate.isPlaying != isPlaying || oldDelegate.style != style || oldDelegate.progress != progress;
  }
}
