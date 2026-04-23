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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actionText != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      actionText!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
