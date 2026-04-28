import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../data/repositories/station_repository.dart';
import '../../data/models/station.dart';
import '../../data/services/station_api.dart';
import '../../logic/controllers/radio_controller.dart';
import '../../logic/controllers/favorites_controller.dart';
import '../../logic/controllers/recording_controller.dart';
import '../../core/theme/rfm_theme.dart';
import '../widgets/hero_station_card.dart';
import '../widgets/section_header.dart';
import '../widgets/city_station_card.dart';
import '../widgets/station_list_tile.dart';
import '../widgets/mini_player.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'search_screen.dart';
import 'player_screen.dart';

final recommendedStationsProvider = FutureProvider<List<Station>>((ref) {
  final api = StationApi();
  return api.getStations(recommend: true, limit: 15).then((data) => data['stations'] as List<Station>);
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final stationsAsync = ref.watch(stationsProvider);
        final radioState = ref.watch(radioControllerProvider);

        return Scaffold(
          backgroundColor: RFMTheme.surface,
          body: Stack(
            children: [
              // Cinematic Background Blobs (Simulated)
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: RFMTheme.blob1,
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: RFMTheme.blob2,
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

              // Main Scrollable Content
              SafeArea(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    // Dashboard View (Index 0)
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Web-style App Bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              children: [
                                // Animated Badge (Live Pulse)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: RFMTheme.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: RFMTheme.primary.withOpacity(0.1),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: RFMTheme.accent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: RFMTheme.accent,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'LIVE NAGPUR PULSE',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.5,
                                          color: RFMTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Hero Title
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'NAGPUR\n',
                                        style: Theme.of(context).textTheme.displayLarge,
                                      ),
                                      TextSpan(
                                        text: 'PULSE.',
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          color: Colors.white10,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ],
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

                        // 2. Your Favorites Section (Personalized Rail)
                        SliverToBoxAdapter(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final favorites = ref.watch(favoritesControllerProvider);
                              if (favorites.isEmpty) return const SizedBox.shrink();
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(
                                    title: 'Saved\nSignals',
                                    subtitle: 'Your Favorites',
                                  ),
                                  SizedBox(
                                    height: 340,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: favorites.length,
                                      padding: const EdgeInsets.only(right: 24),
                                      itemBuilder: (context, index) {
                                        final station = favorites[index];
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
                          ),
                        ),

                        // 2.1 Tape Deck (Recorded Signals)
                        SliverToBoxAdapter(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final recState = ref.watch(recordingControllerProvider);
                              if (recState.tapes.isEmpty) return const SizedBox.shrink();
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(
                                    title: 'Tape\nDeck',
                                    subtitle: 'Your Recordings',
                                  ),
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: recState.tapes.length,
                                      padding: const EdgeInsets.only(left: 24, right: 24),
                                      itemBuilder: (context, index) {
                                        final tape = recState.tapes[index];
                                        return Container(
                                          width: 220,
                                          margin: const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(LucideIcons.playCircle, color: Color(0xFFD4AF37), size: 32),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      tape.stationName,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      '${tape.duration.inMinutes}m ${tape.duration.inSeconds % 60}s • ${tape.timestamp.day}/${tape.timestamp.month}',
                                                      style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.3)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(LucideIcons.trash2, size: 14, color: Colors.white10),
                                                onPressed: () => ref.read(recordingControllerProvider.notifier).deleteTape(tape),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              );
                            },
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
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 800),
                                    tween: Tween(begin: 0, end: 1),
                                    curve: Curves.easeOutQuart,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 30 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: const SectionHeader(
                                      title: 'Local\nTransmission',
                                      subtitle: 'In Your City',
                                      actionText: 'Scan All',
                                    ),
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

                        // 4. Discovery Mode (Recommendations)
                        SliverToBoxAdapter(
                          child: ref.watch(recommendedStationsProvider).when(
                            data: (recommended) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(
                                    title: 'Smart\nDiscovery',
                                    subtitle: 'Recommended For You',
                                  ),
                                  SizedBox(
                                    height: 340,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: recommended.length,
                                      padding: const EdgeInsets.only(right: 24),
                                      itemBuilder: (context, index) {
                                        final station = recommended[index];
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

                        // 5. All India Radios
                        SliverToBoxAdapter(
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0, end: 1),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 40 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: const SectionHeader(
                              title: 'National\nNetwork',
                              subtitle: 'All India Radios',
                            ),
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
                                    padding: EdgeInsets.only(
                                      left: isAsymmetrical ? 48 : 0,
                                      right: isAsymmetrical ? 0 : 0,
                                      bottom: 4,
                                    ),
                                    child: Transform.translate(
                                      offset: Offset(isAsymmetrical ? -12 : 0, 0),
                                      child: StationListTile(
                                        station: station,
                                        isActive: radioState.currentStation?.changeuuid == station.changeuuid,
                                        onTap: () => ref.read(radioControllerProvider.notifier).setStation(station),
                                      ),
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
                          child: SizedBox(height: 180),
                        ),
                      ],
                    ),

                    // Player View (Index 1) - Reuses the PlayerScreen content
                    PlayerScreen(),

                    // Search/Explore View (Index 2)
                    const SearchScreen(),
                  ],
                ),
              ),

              // Mini Player (Tonal Depth Layer)
              if (radioState.currentStation != null && _currentIndex == 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 106, // Lifted slightly to be above Nav Bar comfortably
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: RFMTheme.surfaceContainerHigh.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: RFMTheme.outline.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
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
                        color: RFMTheme.surfaceContainerLowest.withOpacity(0.75),
                        border: Border(
                          top: BorderSide(
                            color: RFMTheme.outline.withOpacity(0.15),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(context, Icons.home_filled, 'HOME', _currentIndex == 0, 0),
                          _buildNavItem(context, Icons.radio_rounded, 'PLAYER', _currentIndex == 1, 1),
                          _buildNavItem(context, Icons.search_rounded, 'SEARCH', _currentIndex == 2, 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? RFMTheme.primaryContainer.withOpacity(0.12) : Colors.transparent,
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
