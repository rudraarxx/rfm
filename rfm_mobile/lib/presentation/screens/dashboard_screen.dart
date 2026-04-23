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
import '../../logic/providers/favorites_provider.dart';
import '../../logic/providers/history_provider.dart';
import '../widgets/station_detail_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late ScrollController _cityScrollController;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _cityScrollController = ScrollController();
    _cityScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_cityScrollController.hasClients) {
      final max = _cityScrollController.position.maxScrollExtent;
      if (max > 0) {
        setState(() {
          _scrollProgress = _cityScrollController.offset / max;
        });
      }
    }
  }

  @override
  void dispose() {
    _cityScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsProvider);
    final radioState = ref.watch(radioControllerProvider);
    final locationState = ref.watch(locationProvider);
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);

    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location unavailable. Showing ${next.city}.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

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
                        onPlayTap: () => ref.read(radioControllerProvider.notifier).setStation(currentStation, queue: stations),
                      );
                    },
                    loading: () => const SizedBox(height: 380, child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // Editorial Spacer
                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                // Recent Transmissions Section
                if (history.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Recent\nTransmissions',
                          subtitle: 'Last played',
                        ),
                        SizedBox(
                          height: 360,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: history.length,
                            padding: const EdgeInsets.only(right: 24),
                            itemBuilder: (context, index) {
                              final station = history[index];
                              return CityStationCard(
                                station: station,
                                isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                                onTap: () => ref.read(radioControllerProvider.notifier).setStation(station, queue: history),
                                isFavorite: favorites.contains(station.changeuuid),
                                onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                                onLongPress: () => showStationDetail(context, station),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),

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
                            height: 360,
                            child: ListView.builder(
                              controller: _cityScrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: cityStations.length,
                              padding: const EdgeInsets.only(right: 24),
                              itemBuilder: (context, index) {
                                final station = cityStations[index];
                                return CityStationCard(
                                  station: station,
                                  isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                                  onTap: () => ref.read(radioControllerProvider.notifier).setStation(station, queue: cityStations),
                                  isFavorite: favorites.contains(station.changeuuid),
                                  onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                                  onLongPress: () => showStationDetail(context, station),
                                );
                              },
                            ),
                          ),
                          // Machinist Scroll Indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Stack(
                              children: [
                                Container(
                                  height: 2,
                                  width: double.infinity,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  height: 2,
                                  width: MediaQuery.of(context).size.width * 0.3 + 
                                         (MediaQuery.of(context).size.width * 0.7 * _scrollProgress),
                                  color: RFMTheme.primaryContainer,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOCAL SIGNAL LOST',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: RFMTheme.primaryContainer,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => ref.refresh(cityStationsProvider),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              color: RFMTheme.surfaceContainerHigh,
                              child: Text(
                                'RETRY',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: RFMTheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Editorial Spacer
                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                // Saved Frequencies Section
                if (favorites.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Saved\nFrequencies',
                          subtitle: 'Your stations',
                        ),
                        stationsAsync.when(
                          data: (stations) {
                            final saved = stations.where((s) => favorites.contains(s.changeuuid)).toList();
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: saved.length,
                              itemBuilder: (context, index) {
                                final station = saved[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: StationListTile(
                                    station: station,
                                    isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                                    onTap: () => ref.read(radioControllerProvider.notifier).setStation(station, queue: saved),
                                    isFavorite: true,
                                    onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                                    onLongPress: () => showStationDetail(context, station),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (err, st) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),

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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: StationListTile(
                              station: station,
                              isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                              onTap: () => ref.read(radioControllerProvider.notifier).setStation(station, queue: stations),
                              isFavorite: favorites.contains(station.changeuuid),
                              onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                              onLongPress: () => showStationDetail(context, station),
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
                  error: (err, st) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NATIONAL SIGNAL LOST',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: RFMTheme.primaryContainer,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => ref.refresh(stationsProvider),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              color: RFMTheme.surfaceContainerHigh,
                              child: Text(
                                'RETRY',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: RFMTheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
