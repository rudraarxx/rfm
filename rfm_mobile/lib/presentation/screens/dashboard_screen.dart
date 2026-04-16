import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/repositories/station_repository.dart';
import '../../logic/controllers/radio_controller.dart';
import '../widgets/hero_station_card.dart';
import '../widgets/horizontal_station_card.dart';
import '../widgets/list_station_card.dart';
import '../widgets/mini_player.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);
    final radioState = ref.watch(radioControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main Scrollable Content
          SafeArea(
            child: stationsAsync.when(
              data: (stations) {
                // Determine Featured Station (Last played or first in list)
                final featuredStation = radioState.currentStation ?? stations.first;

                // Filter City Stations (Hardcoded to Nagpur for this iteration)
                final cityStations = stations.where((s) => 
                  s.tags?.contains('nagpur') == true || 
                  s.state == 'Maharashtra'
                ).toList();

                // All India Radios (Exclude featured if desired, or show all)
                final nationalStations = stations;

                return CustomScrollView(
                  slivers: [
                    // Top App Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.activity, color: Theme.of(context).colorScheme.primaryContainer),
                                const SizedBox(width: 12),
                                Text(
                                  'THE MACHINIST',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(LucideIcons.user, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 1. Featured Section (Hero)
                    SliverToBoxAdapter(
                      child: HeroStationCard(
                        station: featuredStation,
                        onPlay: () => ref.read(radioControllerProvider.notifier).setStation(featuredStation),
                      ),
                    ),

                    // Spacing
                    const SliverToBoxAdapter(child: SizedBox(height: 48)),

                    // 2. City Section - LOCAL TRANSMISSION
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'LOCAL TRANSMISSION',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                Text(
                                  'SCAN ALL',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'IN YOUR CITY',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 280,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          itemCount: cityStations.length,
                          itemBuilder: (context, index) {
                            return HorizontalStationCard(
                              station: cityStations[index],
                              onTap: () => ref.read(radioControllerProvider.notifier).setStation(cityStations[index]),
                            );
                          },
                        ),
                      ),
                    ),

                    // Spacing
                    const SliverToBoxAdapter(child: SizedBox(height: 64)),

                    // 3. National Section - ALL INDIA RADIOS
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NATIONAL NETWORK',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ALL INDIA RADIOS',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ListStationCard(
                              station: nationalStations[index],
                              onTap: () => ref.read(radioControllerProvider.notifier).setStation(nationalStations[index]),
                            );
                          },
                          childCount: nationalStations.length,
                        ),
                      ),
                    ),

                    // Bottom padding for mini-player
                    const SliverToBoxAdapter(child: SizedBox(height: 160)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),

          // Mini Player - Floating Glass Element
          if (radioState.currentStation != null)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(),
            ),
        ],
      ),
    );
  }
}
