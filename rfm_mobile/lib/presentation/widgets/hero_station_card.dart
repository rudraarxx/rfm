import 'package:flutter/material.dart';
import '../../data/models/station.dart';
import '../../core/theme/rfm_theme.dart';

class HeroStationCard extends StatelessWidget {
  final Station station;
  final bool isPlaying;
  final VoidCallback onPlayTap;

  const HeroStationCard({
    super.key,
    required this.station,
    required this.isPlaying,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Station Info Card (Studios Quality Style)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RFMTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Artwork
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: RFMTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        image: station.favicon != null && station.favicon!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(station.favicon!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: station.favicon == null || station.favicon!.isEmpty
                        ? const Icon(Icons.radio_rounded, color: RFMTheme.primary, size: 24)
                        : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STUDIO QUALITY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              letterSpacing: 2,
                              color: RFMTheme.primary.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            station.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Tags & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOCATION',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          station.state?.toUpperCase() ?? 'NAGPUR',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onPlayTap,
                      child: const Text('TUNE SIGNAL'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tagline below card
          Text(
            'CURATED RADIO SHELL FOR THE ANALOG SOUL.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}
