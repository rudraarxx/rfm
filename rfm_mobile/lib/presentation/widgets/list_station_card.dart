import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/station.dart';

class ListStationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const ListStationCard({
    super.key,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Technical Thumbnail
              Container(
                width: 80,
                height: 80,
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: station.favicon != null
                    ? Opacity(
                        opacity: 0.8,
                        child: Image.network(
                          station.favicon!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Opacity(
                        opacity: 0.2,
                        child: Icon(LucideIcons.radio, color: Theme.of(context).colorScheme.onSurface),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            station.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.radioReceiver, 
                          size: 14, 
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDescription(station),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Chip(label: (station.state ?? 'INDIA').toUpperCase()),
                        const SizedBox(width: 8),
                        _Chip(label: _getFreqLabel(station)),
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

  String _getDescription(Station s) {
    if (s.tags != null && s.tags!.isNotEmpty) {
      return s.tags!.split(',').take(3).join(' & ').toUpperCase();
    }
    return 'NATIONAL BROADCAST NETWORK';
  }

  String _getFreqLabel(Station s) {
    if (s.name.contains('91.1')) return '91.1 FM';
    if (s.name.contains('98.3')) return '98.3 FM';
    if (s.name.contains('92.7')) return '92.7 FM';
    return 'DIGITAL';
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
