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
        color: RFMTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.zero,
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
              height: 3,
              color: Colors.white12,
            ),
          ),
          const SizedBox(height: 24),

          // Header: favicon + name + favorite
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: RFMTheme.surfaceContainerLowest,
                  border: Border.all(color: Colors.white10),
                ),
                child: station.favicon != null && station.favicon!.isNotEmpty
                    ? Image.network(station.favicon!, fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Icon(Icons.radio_rounded, color: Colors.white24, size: 32))
                    : const Icon(Icons.radio_rounded, color: Colors.white24, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                    ),
                    if (station.city != null || station.state != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [station.city, station.state].whereType<String>().join(', ').toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: RFMTheme.primaryContainer,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
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
                  color: isFavorite ? RFMTheme.primaryContainer : Colors.white38,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

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
                _MetaPill(label: station.language!.toUpperCase()),
              if (station.established != null && station.established!.isNotEmpty)
                _MetaPill(label: 'EST. ${station.established!}'),
              if (station.votes != null)
                _MetaPill(label: '♥ ${station.votes}'),
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
                  .take(6)
                  .map((tag) => _TagChip(tag: tag))
                  .toList(),
            ),
          ],

          const SizedBox(height: 24),

          // Links row
          Row(
            children: [
              if (station.homepage != null && station.homepage!.isNotEmpty)
                _LinkButton(
                  icon: Icons.language_rounded,
                  label: 'WEBSITE',
                  onTap: () => _launch(station.homepage!),
                ),
              if (station.homepage != null && station.homepage!.isNotEmpty && station.contactNumber != null)
                const SizedBox(width: 12),
              if (station.contactNumber != null && station.contactNumber!.isNotEmpty)
                _LinkButton(
                  icon: Icons.phone_rounded,
                  label: 'CONTACT',
                  onTap: () => _launch('tel:${station.contactNumber!}'),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Play button
          GestureDetector(
            onTap: () {
              ref.read(radioControllerProvider.notifier).setStation(station);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: const BoxDecoration(
                gradient: RFMTheme.primaryGradient,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'TUNE IN',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? RFMTheme.primaryContainer.withValues(alpha: 0.15)
            : RFMTheme.surfaceContainerLowest,
        border: Border.all(
          color: highlight ? RFMTheme.primaryContainer.withValues(alpha: 0.4) : Colors.white10,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: highlight ? RFMTheme.primaryContainer : Colors.white60,
          letterSpacing: 0.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        tag.toUpperCase(),
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 1),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: RFMTheme.surfaceContainerLowest,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
                letterSpacing: 1,
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
