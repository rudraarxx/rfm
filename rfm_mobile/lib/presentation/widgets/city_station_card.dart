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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 300,
        margin: const EdgeInsets.only(left: 24, bottom: 20),
        decoration: BoxDecoration(
          color: widget.isActive ? RFMTheme.surfaceContainerHigh : RFMTheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: widget.isActive ? RFMTheme.primaryContainer : Colors.transparent,
              width: 3,
            ),
          ),
          boxShadow: [
            if (widget.isActive)
              BoxShadow(
                color: RFMTheme.primaryContainer.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High-Impact Image Area
            ClipRect(
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Zooming Background Image
                    AnimatedScale(
                      scale: widget.isActive ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        decoration: BoxDecoration(
                          color: RFMTheme.surfaceContainerLowest,
                          image: widget.station.favicon != null && widget.station.favicon!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.station.favicon!),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(widget.isActive ? 0.2 : 0.4),
                                    BlendMode.darken,
                                  ),
                                )
                              : null,
                        ),
                        child: widget.station.favicon == null || widget.station.favicon!.isEmpty
                            ? Center(
                                child: Icon(
                                  Icons.radio_rounded,
                                  color: RFMTheme.onSurface.withOpacity(0.05),
                                  size: 80,
                                ),
                              )
                            : null,
                      ),
                    ),
                    
                    // Live Scanning Line Animation
                    if (widget.isActive)
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (context, child) {
                          return Positioned(
                            top: 220 * _scanController.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.15),
                                    blurRadius: 2,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    
                    // Favorite (Top-Right)
                    if (widget.onFavoriteTap != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: widget.onFavoriteTap,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            color: Colors.black45,
                            child: Icon(
                              widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: widget.isFavorite ? RFMTheme.primaryContainer : Colors.white54,
                            ),
                          ),
                        ),
                      ),

                    // Frequency Tag (Bottom-Left)
                    if (widget.station.frequency != null && widget.station.frequency!.isNotEmpty)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: FadeTransition(
                          opacity: widget.isActive ? _pulseController : const AlwaysStoppedAnimation(1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            color: RFMTheme.primaryContainer,
                            child: Text(
                              'FM ${widget.station.frequency!.toUpperCase()}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Text Content Area
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.station.name.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.5,
                          color: widget.isActive ? Colors.white : Colors.white.withOpacity(0.9),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.station.tags?.split(',').map((t) => t.trim()).take(2).join(' & ') ?? 'Transmitting...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RFMTheme.onSurface.withOpacity(0.4),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

