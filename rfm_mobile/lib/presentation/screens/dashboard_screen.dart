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
import '../../logic/providers/location_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);
    final radioState = ref.watch(radioControllerProvider);
    final locationState = ref.watch(locationProvider);

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
                        GestureDetector(
                          onTap: () => _showLocationDialog(context, ref),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: RFMTheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: locationState.isLoading ? RFMTheme.primaryContainer : RFMTheme.onSurface.withOpacity(0.4),
                              size: 24,
                            ),
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
                  child: ref.watch(cityStationsProvider).when(
                    data: (cityStations) {
                      if (cityStations.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Local\nTransmission',
                            subtitle: 'In ${locationState.city}',
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

        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref) {
    final cityController = TextEditingController(text: ref.read(locationProvider).city);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RFMTheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'SELECT LOCATION',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: RFMTheme.primaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Enter City Name',
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(locationProvider.notifier).detectLocation();
                },
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('AUTO-DETECT'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: RFMTheme.onSurface.withOpacity(0.4)),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(locationProvider.notifier).updateCity(cityController.text);
              Navigator.pop(context);
            },
            child: const Text('CONFIRM', style: TextStyle(color: RFMTheme.primaryContainer)),
          ),
        ],
      ),
    );
  }
}
