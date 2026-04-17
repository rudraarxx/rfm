import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onActionTap;
  final String? actionText;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onActionTap,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFDA1A32),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
              ),
              if (actionText != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionText!.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white24,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  letterSpacing: -0.5,
                  height: 1.0,
                  fontSize: 28,
                ),
          ),
        ],
      ),
    );
  }
}
