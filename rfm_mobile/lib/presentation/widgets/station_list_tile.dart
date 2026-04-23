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
      child: AnimatedScale(
        scale: widget.isActive ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isActive ? RFMTheme.surfaceContainerHigh : RFMTheme.surfaceContainerLow,
            border: Border(
              left: BorderSide(
                color: widget.isActive ? RFMTheme.primaryContainer : Colors.transparent,
                width: 4,
              ),
            ),
            boxShadow: [
              if (widget.isActive)
                BoxShadow(
                  color: RFMTheme.primaryContainer.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(-8, 0),
                ),
            ],
          ),
          child: Row(
            children: [
              // Logo in Digital Chassis
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: RFMTheme.surfaceContainerLowest,
                  border: Border.all(
                    color: RFMTheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: widget.station.favicon != null && widget.station.favicon!.isNotEmpty
                      ? Image.network(
                          widget.station.favicon!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),
              const SizedBox(width: 20),
              
              // Station technical info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.station.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: -0.5,
                            color: widget.isActive ? Colors.white : Colors.white.withOpacity(0.85),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (widget.station.tags != null && widget.station.tags!.isNotEmpty)
                      Text(
                        widget.station.tags!.split(',').map((t) => t.trim()).take(3).join(' & '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: RFMTheme.onSurface.withOpacity(0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.station.city != null && widget.station.city!.isNotEmpty)
                          _buildTechPill(context, widget.station.city!.toUpperCase()),
                        if (widget.station.city != null && widget.station.city!.isNotEmpty)
                          const SizedBox(width: 8),
                        if (widget.station.frequency != null && widget.station.frequency!.isNotEmpty)
                          _buildTechPill(context, 'FM ${widget.station.frequency!.toUpperCase()}'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),

              // Right controls: favorite + signal
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.onFavoriteTap != null)
                    GestureDetector(
                      onTap: widget.onFavoriteTap,
                      child: Icon(
                        widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: widget.isFavorite ? RFMTheme.primaryContainer : Colors.white24,
                      ),
                    ),
                  if (widget.onFavoriteTap != null) const SizedBox(height: 8),
                  FadeTransition(
                    opacity: widget.isActive ? _pulseController : const AlwaysStoppedAnimation(0.2),
                    child: Icon(
                      Icons.sensors_rounded,
                      size: 20,
                      color: widget.isActive ? RFMTheme.primaryContainer : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Icon(
      Icons.radio_rounded,
      color: RFMTheme.onSurface.withOpacity(0.1),
      size: 24,
    );
  }

  Widget _buildTechPill(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: RFMTheme.surfaceContainerLowest,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: RFMTheme.onSurface.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

