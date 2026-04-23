import 'package:flutter/material.dart';
import '../../data/models/station.dart';
import '../../core/theme/rfm_theme.dart';

class HeroStationCard extends StatelessWidget {
  final Station station;
  final bool isPlaying;
  final VoidCallback onPlayTap;
  final VoidCallback? onLongPress;

  const HeroStationCard({
    super.key,
    required this.station,
    required this.isPlaying,
    required this.onPlayTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: RFMTheme.surface,
            image: station.favicon != null && station.favicon!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(station.favicon!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: Stack(
            children: [
              if (station.favicon == null || station.favicon!.isEmpty)
                const Center(
                  child: Icon(
                    Icons.radio_rounded,
                    color: Colors.white10,
                    size: 120,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Featured Station',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: RFMTheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      station.name,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.white,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (station.tags != null && station.tags!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        station.tags!.split(',').take(3).join(' • ').toUpperCase(),
                        style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: onPlayTap,
                          icon: const Icon(Icons.play_arrow_rounded, size: 28),
                          label: const Text('LISTEN NOW'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
