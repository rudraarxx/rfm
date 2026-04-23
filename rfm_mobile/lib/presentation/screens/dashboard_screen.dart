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
import '../widgets/error_state_widget.dart';

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
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location unavailable. Showing ${next.city}.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Minimalist App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: RFMTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.radio_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'FORGE',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search_rounded, color: Colors.white),
                              onPressed: () {
                                // Search functionality
                              },
                            ),
                            GestureDetector(
                              onTap: () => _showLocationDialog(context, ref),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: RFMTheme.surface,
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: locationState.isLoading ? RFMTheme.primary : Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content Filter Chips (YouTube style)
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        _buildFilterChip(context, 'Relax', isSelected: true),
                        _buildFilterChip(context, 'Energize'),
                        _buildFilterChip(context, 'Workout'),
                        _buildFilterChip(context, 'Focus'),
                        _buildFilterChip(context, 'Commute'),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: stationsAsync.when(
                    data: (stations) {
                      final currentStation = radioState.currentStation ?? (stations.isNotEmpty ? stations.first : null);
                      if (currentStation == null) return const SizedBox.shrink();
                      return HeroStationCard(
                        station: currentStation,
                        isPlaying: radioState.isPlaying,
                        onPlayTap: () => ref.read(radioControllerProvider.notifier).setStation(currentStation, queue: stations),
                        onLongPress: () => showStationDetail(context, currentStation),
                      );
                    },
                    loading: () => const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
                    error: (err, st) => SizedBox(
                      height: 280,
                      child: SignalLostWidget(
                        onRetry: () => ref.refresh(stationsProvider),
                      ),
                    ),
                  ),
                ),

                // Recent Transmissions Section
                if (history.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Listen again',
                          subtitle: '',
                        ),
                        SizedBox(
                          height: 240,
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
                      ],
                    ),
                  ),

                // 2. Local Stations Section
                SliverToBoxAdapter(
                  child: ref.watch(cityStationsProvider).when(
                    data: (cityStations) {
                      if (cityStations.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Quick picks',
                            subtitle: 'Based on ${locationState.city}',
                            actionText: 'Play all',
                            onActionTap: () => ref.read(radioControllerProvider.notifier).setStation(cityStations.first, queue: cityStations),
                          ),
                          SizedBox(
                            height: 240,
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
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, st) => SignalLostWidget(
                      onRetry: () => ref.refresh(cityStationsProvider),
                    ),
                  ),
                ),

                // Recommended Section
                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Recommended for you',
                    subtitle: '',
                  ),
                ),

                stationsAsync.when(
                  data: (stations) => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final station = stations[index];
                          return StationListTile(
                            station: station,
                            isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                            onTap: () => ref.read(radioControllerProvider.notifier).setStation(station, queue: stations),
                            isFavorite: favorites.contains(station.changeuuid),
                            onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                            onLongPress: () => showStationDetail(context, station),
                          );
                        },
                        childCount: stations.length > 20 ? 20 : stations.length, // Limit for better performance on mobile
                      ),
                    ),
                  ),
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, st) => SliverFillRemaining(
                    child: SignalLostWidget(
                      onRetry: () => ref.refresh(stationsProvider),
                    ),
                  ),
                ),

                // Bottom padding for mini-player
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
          // Floating Mini Player
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

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.white10,
        selectedColor: Colors.white,
        checkmarkColor: Colors.black,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref) {
    final cityController = TextEditingController(text: ref.read(locationProvider).city);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF212121),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Change location',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
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
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              ref.read(locationProvider.notifier).updateCity(cityController.text);
              Navigator.pop(context);
            },
            child: const Text('CONFIRM', style: TextStyle(color: RFMTheme.primary)),
          ),
        ],
      ),
    );
  }
}
