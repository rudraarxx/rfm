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
    final spectrum = ref.watch(spectrumProvider).value ?? List.generate(60, (_) => 0.05);

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
    switch (style) {
      case 'radial':
        _paintRadial(canvas, size);
        break;
      case 'wave':
        _paintWave(canvas, size);
        break;
      case 'dots':
        _paintDotMatrix(canvas, size);
        break;
      case 'classic':
      default:
        _paintClassic(canvas, size);
        break;
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

  void _paintRadial(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < amplitudes.length; i++) {
      final angle = (i / amplitudes.length) * 2 * math.pi;
      final barLen = 20 * amplitudes[i];
      
      final start = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + barLen) * math.cos(angle),
        center.dy + (radius + barLen) * math.sin(angle),
      );
      
      canvas.drawLine(start, end, paint);
    }
  }

  void _paintWave(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (var i = 0; i < amplitudes.length; i++) {
      final x = (i / (amplitudes.length - 1)) * size.width;
      final y = size.height / 2 - (size.height / 2 * amplitudes[i]);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = ((i - 1) / (amplitudes.length - 1)) * size.width;
        final prevY = size.height / 2 - (size.height / 2 * amplitudes[i - 1]);
        path.quadraticBezierTo(prevX, prevY, (x + prevX) / 2, (y + prevY) / 2);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);

    // Draw line on top
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
  }

  void _paintDotMatrix(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.5);
    const dotsCount = 10;
    final dotSize = size.height / (dotsCount * 2);

    final barWidth = size.width / (amplitudes.length * 1.5);
    final gap = barWidth * 0.5;

    for (var i = 0; i < amplitudes.length; i++) {
      final activeDots = (amplitudes[i] * dotsCount).round();
      final x = i * (barWidth + gap) + (size.width - (amplitudes.length * (barWidth + gap))) / 2;
      
      for (var j = 0; j < dotsCount; j++) {
        final y = size.height - (j * dotSize * 2);
        paint.color = j < activeDots ? color : color.withOpacity(0.05);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barWidth, dotSize),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant VisualizerPainter oldDelegate) {
    return isPlaying || oldDelegate.isPlaying != isPlaying || oldDelegate.style != style || oldDelegate.progress != progress;
  }
}
