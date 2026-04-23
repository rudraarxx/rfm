import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/rfm_theme.dart';
import '../../data/models/station.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/providers/favorites_provider.dart';

class StationDetailSheet extends ConsumerWidget {
  final Station station;

  const StationDetailSheet({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(station.changeuuid);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header: favicon + name + favorite
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.black,
                  child: station.favicon != null && station.favicon!.isNotEmpty
                      ? Image.network(station.favicon!, fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => const Icon(Icons.radio_rounded, color: Colors.white24, size: 32))
                      : const Icon(Icons.radio_rounded, color: Colors.white24, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                    ),
                    if (station.city != null || station.state != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [station.city, station.state].whereType<String>().join(', '),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white60,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? RFMTheme.primary : Colors.white38,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Metadata pills row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (station.frequency != null && station.frequency!.isNotEmpty)
                _MetaPill(label: 'FM ${station.frequency!}', highlight: true),
              if (station.bitrate != null)
                _MetaPill(label: '${station.bitrate} kbps'),
              if (station.language != null && station.language!.isNotEmpty)
                _MetaPill(label: station.language!),
              if (station.established != null && station.established!.isNotEmpty)
                _MetaPill(label: 'Est. ${station.established!}'),
            ],
          ),

          // Tags
          if (station.tags != null && station.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: station.tags!
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .take(8)
                  .map((tag) => _TagChip(tag: tag))
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),

          // Links row
          Row(
            children: [
              if (station.homepage != null && station.homepage!.isNotEmpty)
                _LinkButton(
                  icon: Icons.language_rounded,
                  label: 'Website',
                  onTap: () => _launch(station.homepage!),
                ),
              if (station.homepage != null && station.homepage!.isNotEmpty && station.contactNumber != null)
                const SizedBox(width: 12),
              if (station.contactNumber != null && station.contactNumber!.isNotEmpty)
                _LinkButton(
                  icon: Icons.phone_rounded,
                  label: 'Contact',
                  onTap: () => _launch('tel:${station.contactNumber!}'),
                ),
            ],
          ),

          const SizedBox(height: 32),

          // Play button
          ElevatedButton(
            onPressed: () {
              ref.read(radioControllerProvider.notifier).setStation(station);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, size: 24),
                SizedBox(width: 8),
                Text(
                  'Listen Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final bool highlight;

  const _MetaPill({required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? Colors.white : Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: highlight ? Colors.black : Colors.white70,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 11, color: Colors.white60),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showStationDetail(BuildContext context, Station station) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => StationDetailSheet(station: station),
  );
}
