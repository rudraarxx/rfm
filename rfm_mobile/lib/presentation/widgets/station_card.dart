import 'package:flutter/material.dart';
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
      borderRadius: BorderRadius.circular(30),
      child: GlassContainer(
        borderRadius: 30,
        color: isActive 
            ? const Color(0xFFD4AF37).withOpacity(0.15) 
            : null,
        borderOpacity: isActive ? 0.4 : 0.1,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(22),
                  image: station.favicon != null
                      ? DecorationImage(
                          image: NetworkImage(station.favicon!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: station.favicon == null
                    ? const Icon(Icons.music_note, color: Color(0xFFD4AF37), size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              station.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              station.tags?.split(',').first ?? 'Nagpur Pulse',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
