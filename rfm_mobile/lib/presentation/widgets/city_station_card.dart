import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../data/models/station.dart';
import '../../core/theme/rfm_theme.dart';

class CityStationCard extends StatelessWidget {
  final Station station;
  final bool isActive;
  final VoidCallback onTap;

  const CityStationCard({
    super.key,
    required this.station,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(left: 24),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Sharp Corners and Overlay Tag
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: RFMTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.zero,
                    image: station.favicon != null && station.favicon!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(station.favicon!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: station.favicon == null || station.favicon!.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.radio, 
                          color: RFMTheme.onSurface.withOpacity(0.05), 
                          size: 64,
                        ),
                      )
                    : null,
                ),
                // Red Tag Overlay
                Positioned(
                  left: 0,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: RFMTheme.primary,
                    child: Text(
                      'FM ${station.votes != null ? (station.votes! / 10).toStringAsFixed(1) : "91.1"}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Technical Metadata Info
            Text(
              'IN YOUR CITY / LOCAL TRANSMISSION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: RFMTheme.onSurface.withOpacity(0.2),
                    fontSize: 8,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              station.name.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    fontSize: 18,
                    color: Colors.white,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              station.tags?.split(',').take(2).join(' • ') ?? 'INDUSTRIAL BEATS',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RFMTheme.onSurface.withOpacity(0.25),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
