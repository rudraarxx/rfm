import 'package:flutter/material.dart';
import '../../core/theme/rfm_theme.dart';

class SignalLostWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const SignalLostWidget({
    super.key,
    required this.onRetry,
    this.message = 'SIGNAL LOST',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white10,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.white10),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 20),
                SizedBox(width: 8),
                Text('TAP TO RETRY'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
