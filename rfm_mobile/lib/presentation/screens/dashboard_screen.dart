import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../data/repositories/station_repository.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../core/theme/rfm_theme.dart';
import '../widgets/hero_station_card.dart';
import '../widgets/section_header.dart';
import '../widgets/city_station_card.dart';
import '../widgets/station_list_tile.dart';
import '../widgets/mini_player.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);
    final radioState = ref.watch(radioControllerProvider);

    return Scaffold(
      backgroundColor: RFMTheme.surface,
      body: Stack(
        children: [
          // Main Scrollable Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Editorial App Bar (Asymmetrical)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.equalizer_rounded,
                              color: RFMTheme.primaryContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'THE MACHINIST',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: 20,
                                    letterSpacing: 1,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: RFMTheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: RFMTheme.onSurface.withOpacity(0.4),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: stationsAsync.when(
                    data: (stations) {
                      final currentStation = radioState.currentStation ?? stations.first;
                      return HeroStationCard(
                        station: currentStation,
                        isPlaying: radioState.isPlaying,
                        onPlayTap: () => ref.read(radioControllerProvider.notifier).setStation(currentStation),
                      );
                    },
                    loading: () => const SizedBox(height: 380, child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // Editorial Spacer
                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                // 2. In Your City Section (Horizontal Rail)
                SliverToBoxAdapter(
                  child: stationsAsync.when(
                    data: (stations) {
                      final cityStations = stations.where((s) => 
                        (s.state?.toLowerCase().contains('nagpur') ?? false) || 
                        (s.tags?.toLowerCase().contains('nagpur') ?? false) ||
                        (s.state?.toLowerCase().contains('maharashtra') ?? false)
                      ).toList();

                      if (cityStations.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            title: 'Local\nTransmission',
                            subtitle: 'In Your City',
                            actionText: 'Scan All',
                          ),
                          SizedBox(
                            height: 340,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: cityStations.length,
                              padding: const EdgeInsets.only(right: 24),
                              itemBuilder: (context, index) {
                                final station = cityStations[index];
                                return CityStationCard(
                                  station: station,
                                  isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                                  onTap: () => ref.read(radioControllerProvider.notifier).setStation(station),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // Editorial Spacer
                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                // 3. All India Radios (2+1 Staggered Layout)
                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'National\nNetwork',
                    subtitle: 'All India Radios',
                  ),
                ),

                stationsAsync.when(
                  data: (stations) => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final station = stations[index];
                          // 2+1 Layout Principle:
                          // Every 3rd item gets asymmetrical treatment (shift and width)
                          final isAsymmetrical = (index + 1) % 3 == 0;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: StationListTile(
                              station: station,
                              isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                              onTap: () => ref.read(radioControllerProvider.notifier).setStation(station),
                            ),
                          );
                        },
                        childCount: stations.length,
                      ),
                    ),
                  ),
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    child: Center(child: Text('Error: $err')),
                  ),
                ),

                // Bottom padding for mini-player
                const SliverToBoxAdapter(
                  child: SizedBox(height: 140),
                ),
              ],
            ),
          ),

          // Mini Player (Tonal Depth Layer)
          if (radioState.currentStation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 90,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: RFMTheme.surfaceContainerHigh.withOpacity(0.8),
                    child: const MiniPlayer(),
                  ),
                ),
              ),
            ),

          // Glassmorphism Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: RFMTheme.surfaceContainerLowest.withOpacity(0.7),
                    border: Border(
                      top: BorderSide(
                        color: RFMTheme.outline.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(context, Icons.stop_circle_rounded, 'HOME', true),
                      _buildNavItem(context, Icons.radio_rounded, 'PLAYER', false),
                      _buildNavItem(context, Icons.search_rounded, 'SEARCH', false),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? RFMTheme.primaryContainer.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: isActive ? RFMTheme.primaryContainer : RFMTheme.onSurface.withOpacity(0.4),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isActive ? RFMTheme.primaryContainer : RFMTheme.onSurface.withOpacity(0.3),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
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
}
