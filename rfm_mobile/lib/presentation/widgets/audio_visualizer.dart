import 'dart:math' as math;
import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
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
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _amplitudes = List.generate(30, (index) => 0.2 + math.Random().nextDouble() * 0.8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: VisualizerPainter(
            isPlaying: widget.isPlaying,
            style: widget.style,
            progress: _controller.value,
            amplitudes: _amplitudes,
            color: widget.color ?? const Color(0xFFD4AF37),
          ),
        );
      },
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
      double heightMultiplier = isPlaying 
          ? (0.3 + 0.7 * math.sin(progress * 2 * math.pi + i * 0.5).abs()) 
          : 0.1;
          
      final barHeight = size.height * amplitudes[i] * heightMultiplier;
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
      double heightMultiplier = isPlaying 
          ? (0.2 + 0.8 * math.cos(progress * 3 * math.pi + i * 0.8).abs()) 
          : 0.05;
          
      final barHeight = size.height * amplitudes[i] * heightMultiplier;
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
