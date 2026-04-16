import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/station.dart';

class HorizontalStationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const HorizontalStationCard({
    super.key,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Container
            AspectRatio(
              aspectRatio: 1.2,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      image: station.favicon != null
                          ? DecorationImage(
                              image: NetworkImage(station.favicon!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.2),
                                BlendMode.darken,
                              ),
                            )
                          : null,
                    ),
                    child: station.favicon == null
                        ? Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary, size: 40)
                        : null,
                  ),
                  // Frequency Tag
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        _getFrequency(station),
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              station.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (station.tags?.split(',').first ?? 'Maharashtra').toUpperCase(),
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

  String _getFrequency(Station s) {
    // Simple logic to extract FM frequency from tags or return a generic one
    if (s.name.contains('91.1')) return 'FM 91.1';
    if (s.name.contains('98.3')) return 'FM 98.3';
    if (s.name.contains('92.7')) return 'FM 92.7';
    if (s.name.contains('93.5')) return 'FM 93.5';
    return 'LIVE';
  }
}
