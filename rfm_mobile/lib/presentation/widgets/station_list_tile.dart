import 'package:flutter/material.dart';
import '../../data/models/station.dart';
import '../../core/theme/rfm_theme.dart';

class StationListTile extends StatefulWidget {
  final Station station;
  final bool isActive;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onLongPress;

  const StationListTile({
    super.key,
    required this.station,
    required this.isActive,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onLongPress,
  });

  @override
  State<StationListTile> createState() => _StationListTileState();
}

class _StationListTileState extends State<StationListTile> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: Row(
          children: [
            // Rounded Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 56,
                height: 56,
                color: RFMTheme.surface,
                child: widget.station.favicon != null && widget.station.favicon!.isNotEmpty
                    ? Image.network(
                        widget.station.favicon!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                      )
                    : _buildPlaceholderIcon(),
              ),
            ),
            const SizedBox(width: 16),
            
            // Station info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.station.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: widget.isActive ? RFMTheme.primary : Colors.white,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (widget.station.tags != null && widget.station.tags!.isNotEmpty)
                    Text(
                      [
                        if (widget.station.frequency != null) '${widget.station.frequency} FM',
                        widget.station.tags!.split(',').first.trim()
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),

            // Right controls
            if (widget.onFavoriteTap != null)
              IconButton(
                onPressed: widget.onFavoriteTap,
                icon: Icon(
                  widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 20,
                  color: widget.isFavorite ? RFMTheme.primary : Colors.white24,
                ),
              ),
            const Icon(
              Icons.more_vert_rounded,
              color: Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.radio_rounded,
        color: Colors.white.withOpacity(0.1),
        size: 28,
      ),
    );
  }
}

