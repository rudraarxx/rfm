import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/rfm_theme.dart';
import '../../data/models/station.dart';
import '../../data/repositories/station_repository.dart';
import '../../logic/providers/favorites_provider.dart';
import '../widgets/station_detail_sheet.dart';
import '../../logic/controllers/radio_controller.dart';
import '../widgets/station_list_tile.dart';

// ── Search UI State ──────────────────────────────────────────────────────────

class SearchUIState {
  final String query;
  final String? selectedState;
  final String? selectedCity;
  final String? selectedLanguage;
  final String? selectedTag;

  const SearchUIState({
    this.query = '',
    this.selectedState,
    this.selectedCity,
    this.selectedLanguage,
    this.selectedTag,
  });

  SearchUIState copyWith({
    String? query,
    Object? selectedState = _sentinel,
    Object? selectedCity = _sentinel,
    Object? selectedLanguage = _sentinel,
    Object? selectedTag = _sentinel,
  }) {
    return SearchUIState(
      query: query ?? this.query,
      selectedState: selectedState == _sentinel ? this.selectedState : selectedState as String?,
      selectedCity: selectedCity == _sentinel ? this.selectedCity : selectedCity as String?,
      selectedLanguage: selectedLanguage == _sentinel ? this.selectedLanguage : selectedLanguage as String?,
      selectedTag: selectedTag == _sentinel ? this.selectedTag : selectedTag as String?,
    );
  }
}

// Sentinel to allow nullable copyWith
const Object _sentinel = Object();

final searchUIProvider = StateProvider<SearchUIState>((ref) => const SearchUIState());

// ── Dedicated top-level providers (no inline FutureProvider inside build) ────

/// Fetches the list of states once. Cached by Riverpod until the graph is disposed.
final statesProvider = FutureProvider<List<String>>((ref) async {
  return ref.read(stationRepositoryProvider).getStates();
});

/// Fetches cities for the currently selected state.
/// Keyed by selected state name — Riverpod caches per family argument.
final citiesForStateProvider = FutureProvider.family<List<String>, String>((ref, state) async {
  return ref.read(stationRepositoryProvider).getCitiesForState(state);
});

/// Unique languages derived from all stations.
final languagesProvider = FutureProvider<List<String>>((ref) async {
  final stations = await ref.watch(stationsProvider.future);
  final langs = stations
      .map((s) => s.language?.trim())
      .whereType<String>()
      .where((l) => l.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return langs;
});

/// Unique tags derived from all stations (top 20 by frequency).
final tagsProvider = FutureProvider<List<String>>((ref) async {
  final stations = await ref.watch(stationsProvider.future);
  final freq = <String, int>{};
  for (final s in stations) {
    if (s.tags == null) continue;
    for (final tag in s.tags!.split(',')) {
      final t = tag.trim().toLowerCase();
      if (t.isNotEmpty) freq[t] = (freq[t] ?? 0) + 1;
    }
  }
  final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(20).map((e) => e.key).toList();
});

/// Fetches stations based on the current search UI state.
final filteredStationsProvider = FutureProvider<List<Station>>((ref) async {
  final searchState = ref.watch(searchUIProvider);
  final repository = ref.read(stationRepositoryProvider);

  final bool hasTextFilter = searchState.query.isNotEmpty;
  final bool hasLocationFilter = searchState.selectedCity != null && searchState.selectedState != null;
  final bool hasExtraFilter = searchState.selectedLanguage != null || searchState.selectedTag != null;

  if (!hasTextFilter && !hasLocationFilter && !hasExtraFilter) return [];

  List<Station> results;
  if (hasTextFilter) {
    results = await repository.searchStations(searchState.query);
  } else if (hasLocationFilter) {
    results = await repository.getStationsByLocation(
      state: searchState.selectedState!,
      city: searchState.selectedCity,
    );
  } else {
    results = await repository.getStations();
  }

  if (searchState.selectedLanguage != null) {
    results = results
        .where((s) => s.language?.toLowerCase().contains(searchState.selectedLanguage!.toLowerCase()) ?? false)
        .toList();
  }
  if (searchState.selectedTag != null) {
    results = results
        .where((s) => s.tags?.toLowerCase().contains(searchState.selectedTag!.toLowerCase()) ?? false)
        .toList();
  }

  return results;
});

// ── Screen ───────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchUIProvider);
    final stationsAsync = ref.watch(filteredStationsProvider);
    final statesAsync = ref.watch(statesProvider);
    final languagesAsync = ref.watch(languagesProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: RFMTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Icon(Icons.grid_view_rounded, color: RFMTheme.primaryContainer, size: 24),
        ),
        title: Text(
          'STATION FINDER',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white24),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Editorial Hero Title
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                children: [
                  const TextSpan(text: 'TUNE '),
                  TextSpan(
                    text: 'INTO\n',
                    style: TextStyle(color: RFMTheme.primaryContainer),
                  ),
                  const TextSpan(text: 'THE VOID'),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── Text Search Bar ──────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: RFMTheme.surfaceContainerLow,
                borderRadius: BorderRadius.zero,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  // Debounce: only update provider if value has actually changed
                  if (val == searchState.query) return;
                  ref.read(searchUIProvider.notifier).state = SearchUIState(query: val);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'SEARCH STATIONS',
                  hintStyle: TextStyle(
                    color: RFMTheme.onSurface.withOpacity(0.2),
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Territory Filter ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: RFMTheme.surfaceContainerLowest.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOCATION FINDER',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: RFMTheme.primaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FILTER BY\nTERRITORY',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                  ),
                ],
              ),
            ),

            // State Dropdown
            _buildDropdown(
              label: 'SELECT STATE',
              value: searchState.selectedState,
              items: statesAsync.value ?? [],
              onChanged: (val) {
                _searchController.clear();
                // Reset city when state changes
                ref.read(searchUIProvider.notifier).state =
                    SearchUIState(selectedState: val);
              },
            ),

            // City Dropdown — only shown when a state is selected
            if (searchState.selectedState != null)
              Builder(builder: (context) {
                final citiesAsync = ref.watch(
                  citiesForStateProvider(searchState.selectedState!),
                );
                return _buildDropdown(
                  label: 'SELECT CITY',
                  value: searchState.selectedCity,
                  items: citiesAsync.value ?? [],
                  onChanged: (val) {
                    ref.read(searchUIProvider.notifier).state =
                        searchState.copyWith(selectedCity: val, query: '');
                    _searchController.clear();
                  },
                );
              }),

            // Language Dropdown
            if (languagesAsync.value?.isNotEmpty ?? false)
              _buildDropdown(
                label: 'SELECT LANGUAGE',
                value: searchState.selectedLanguage,
                items: languagesAsync.value!,
                onChanged: (val) {
                  ref.read(searchUIProvider.notifier).state =
                      searchState.copyWith(selectedLanguage: val);
                },
                clearable: true,
                onClear: () => ref.read(searchUIProvider.notifier).state =
                    searchState.copyWith(selectedLanguage: null),
              ),

            // Tag Chips
            if (tagsAsync.value?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FILTER BY GENRE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white24,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tagsAsync.value!.map((tag) {
                        final isSelected = searchState.selectedTag == tag;
                        return GestureDetector(
                          onTap: () {
                            ref.read(searchUIProvider.notifier).state =
                                searchState.copyWith(
                              selectedTag: isSelected ? null : tag,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? RFMTheme.primaryContainer.withValues(alpha: 0.15)
                                  : RFMTheme.surfaceContainerLowest,
                              border: Border.all(
                                color: isSelected
                                    ? RFMTheme.primaryContainer.withValues(alpha: 0.5)
                                    : Colors.white10,
                              ),
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isSelected ? RFMTheme.primaryContainer : Colors.white38,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 48),

            // ── Results Header ───────────────────────────────────────────────
            if (searchState.selectedCity != null ||
                searchState.query.isNotEmpty ||
                searchState.selectedLanguage != null ||
                searchState.selectedTag != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                      children: [
                        const TextSpan(text: 'STATIONS IN '),
                        TextSpan(
                          text: (searchState.selectedCity ?? searchState.query)
                              .toUpperCase(),
                          style: TextStyle(color: RFMTheme.primaryContainer),
                        ),
                      ],
                    ),
                  ),
                  stationsAsync.maybeWhen(
                    data: (list) => Text(
                      '${list.length} UNITS FOUND',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // ── Results List ─────────────────────────────────────────────────
            stationsAsync.when(
              data: (stations) {
                if (stations.isEmpty &&
                    (searchState.selectedCity != null ||
                        searchState.query.isNotEmpty)) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        'NO SIGNAL FOUND',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white24,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return StationListTile(
                      station: station,
                      isActive: ref
                              .watch(radioControllerProvider)
                              .currentStation
                              ?.changeuuid ==
                          station.changeuuid,
                      onTap: () => ref.read(radioControllerProvider.notifier).setStation(
                            station,
                            queue: List<Station>.from(stations),
                          ),
                      isFavorite: favorites.contains(station.changeuuid),
                      onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                      onLongPress: () => showStationDetail(context, station),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, st) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIGNAL LOST',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: RFMTheme.primaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => ref.refresh(filteredStationsProvider),
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

            const SizedBox(height: 40),

            // View All Button
            if (stationsAsync.value?.isNotEmpty ?? false)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: RFMTheme.surfaceContainerLow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VIEW ALL STATIONS',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool clearable = false,
    VoidCallback? onClear,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: RFMTheme.surfaceContainerLowest.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              if (clearable && value != null && onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Text(
                    'CLEAR',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: RFMTheme.primaryContainer,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: RFMTheme.surfaceContainerHigh,
              icon: const Icon(Icons.unfold_more_rounded, color: Colors.white24, size: 20),
              hint: Text(
                'SELECT',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
