import 'package:flutter/material.dart';
import '../../data/models/station.dart';
import '../../core/theme/rfm_theme.dart';

class StationListTile extends StatelessWidget {
  final Station station;
  final bool isActive;
  final VoidCallback onTap;

  const StationListTile({
    super.key,
    required this.station,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? RFMTheme.surfaceContainerHigh : RFMTheme.surfaceContainerLow,
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          children: [
            // Logo Shielding (Technical Box)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: RFMTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: RFMTheme.outline.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: station.favicon != null && station.favicon!.isNotEmpty
                    ? Image.network(
                        station.favicon!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.radio, 
                          color: RFMTheme.onSurface.withOpacity(0.05), 
                          size: 18,
                        ),
                      )
                    : Icon(
                        Icons.radio, 
                        color: RFMTheme.onSurface.withOpacity(0.05), 
                        size: 18,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0,
                          color: Colors.white.withOpacity(0.9),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTechPill(context, station.state?.toUpperCase() ?? 'INDIA'),
                      const SizedBox(width: 6),
                      _buildTechPill(context, '${station.votes != null ? (station.votes! / 10).toStringAsFixed(1) : "104.2"} FM'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Custom Signal Icon (Bracketed)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '( (',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: RFMTheme.primaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: RFMTheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  ') )',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: RFMTheme.primaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechPill(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: const BoxDecoration(
        color: RFMTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: RFMTheme.onSurface.withOpacity(0.6),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
