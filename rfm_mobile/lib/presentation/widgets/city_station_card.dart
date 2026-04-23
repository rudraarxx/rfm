import 'package:flutter/material.dart';
import '../../data/models/station.dart';
import '../../core/theme/rfm_theme.dart';

class CityStationCard extends StatefulWidget {
  final Station station;
  final bool isActive;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onLongPress;

  const CityStationCard({
    super.key,
    required this.station,
    required this.isActive,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onLongPress,
  });

  @override
  State<CityStationCard> createState() => _CityStationCardState();
}

class _CityStationCardState extends State<CityStationCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: 24, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounded Image Area
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Container(
                      color: RFMTheme.surface,
                      child: widget.station.favicon != null && widget.station.favicon!.isNotEmpty
                          ? Image.network(
                              widget.station.favicon!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.radio_rounded,
                                  color: Colors.white.withOpacity(0.1),
                                  size: 48,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.radio_rounded,
                                color: Colors.white.withOpacity(0.1),
                                size: 48,
                              ),
                            ),
                    ),
                    if (widget.isActive)
                      Container(
                        color: Colors.black38,
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    // Favorite (Top-Right)
                    if (widget.onFavoriteTap != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: widget.onFavoriteTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: widget.isFavorite ? RFMTheme.primary : Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Text Content Area
            Text(
              widget.station.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.isActive ? RFMTheme.primary : Colors.white,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (widget.station.frequency != null && widget.station.frequency!.isNotEmpty) '${widget.station.frequency} FM',
                widget.station.tags?.split(',').first.trim() ?? 'Radio'
              ].join(' • '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: Colors.white54,
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

