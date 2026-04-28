import 'package:flutter/material.dart';
import '../../data/models/station.dart';
import '../../core/theme/rfm_theme.dart';

class HeroStationCard extends StatelessWidget {
  final Station station;
  final bool isPlaying;
  final VoidCallback onPlayTap;

  const HeroStationCard({
    super.key,
    required this.station,
    required this.isPlaying,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      color: RFMTheme.surface,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Image (Right-aligned for asymmetry)
          Positioned(
            right: 0,
            top: 0,
            bottom: 40,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/vintage_radio_hero.png'),
                  fit: BoxFit.cover,
                ),
              ),
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    RFMTheme.surface,
                    RFMTheme.surface.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                // Large Asymmetrical Typography
                Transform.translate(
                  offset: const Offset(-4, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE IRON',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 64,
                              height: 0.85,
                              letterSpacing: -0.04 * 64,
                            ),
                      ),
                      Text(
                        'RHYTHM',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 64,
                              height: 0.85,
                              letterSpacing: -0.04 * 64,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Primary Gradient Button (Sharp Corners)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          onPlayTap();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFFF3B3B),
                                Color(0xFFF45B69),
                              ],
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'LISTEN NOW',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Frequency Info (Technical Detail)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'FREQUENCY',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: RFMTheme.onSurface.withOpacity(0.35),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '104.2 MHZ',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 32,
                                color: RFMTheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
