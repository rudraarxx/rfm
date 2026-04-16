import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/station.dart';
import 'glass_container.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  final bool isActive;

  const StationCard({
    super.key,
    required this.station,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: isActive ? Border.all(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            width: 1,
          ) : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  image: station.favicon != null
                      ? DecorationImage(
                          image: NetworkImage(station.favicon!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.2),
                            BlendMode.dstATop,
                          ),
                        )
                      : null,
                ),
                child: station.favicon == null
                    ? Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              station.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (station.tags?.split(',').first ?? 'Nagpur Pulse').toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
