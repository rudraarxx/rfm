import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/rfm_theme.dart';

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
                      color: RFMTheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      fontSize: 8,
                    ),
              ),
              if (actionText != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionText!.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.1),
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  letterSpacing: -1,
                  height: 1.0,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
