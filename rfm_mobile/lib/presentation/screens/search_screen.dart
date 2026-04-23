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
import '../widgets/error_state_widget.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'SCAN',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white, letterSpacing: 2),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(searchUIProvider.notifier).state = searchState.copyWith(query: val);
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search stations...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Location Filters (PRD 3.2 Hierarchy)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // State Selector
                _FilterButton(
                  label: searchState.selectedState ?? 'All India',
                  isSelected: searchState.selectedState != null,
                  onTap: () => _showStatePicker(context, ref),
                ),
                const SizedBox(width: 8),
                // City Selector (Internal Hierarchy)
                if (searchState.selectedState != null)
                  _FilterButton(
                    label: searchState.selectedCity ?? 'All Cities',
                    isSelected: searchState.selectedCity != null,
                    onTap: () => _showCityPicker(context, ref, searchState.selectedState!),
                  ),
                const SizedBox(width: 8),
                // Language Selector
                _FilterButton(
                  label: searchState.selectedLanguage ?? 'Any Language',
                  isSelected: searchState.selectedLanguage != null,
                  onTap: () => _showLanguagePicker(context, ref),
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 24, color: Colors.white12),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // Filters / Categories (Tags)
          if (tagsAsync.value?.isNotEmpty ?? false)
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: tagsAsync.value!.length,
                itemBuilder: (context, index) {
                  final tag = tagsAsync.value![index];
                  final isSelected = searchState.selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(searchUIProvider.notifier).state =
                            searchState.copyWith(selectedTag: isSelected ? null : tag);
                      },
                      backgroundColor: Colors.white10,
                      selectedColor: Colors.white,
                      checkmarkColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
            ),

          // Results
          Expanded(
            child: stationsAsync.when(
              data: (stations) {
                if (stations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.white10, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'NO SIGNAL FOUND',
                          style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return StationListTile(
                      station: station,
                      isActive: ref.watch(radioControllerProvider).currentStation?.changeuuid == station.changeuuid,
                      onTap: () => ref.read(radioControllerProvider.notifier).setStation(station, queue: stations),
                      isFavorite: favorites.contains(station.changeuuid),
                      onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(station.changeuuid),
                      onLongPress: () => showStationDetail(context, station),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: RFMTheme.primary)),
              error: (err, st) => SignalLostWidget(
                onRetry: () => ref.refresh(filteredStationsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatePicker(BuildContext context, WidgetRef ref) {
    final statesAsync = ref.read(statesProvider);
    statesAsync.whenData((states) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => _PickerList(
          title: 'Select State',
          items: states,
          onSelected: (val) {
            ref.read(searchUIProvider.notifier).state = ref.read(searchUIProvider).copyWith(
                  selectedState: val,
                  selectedCity: null, // Reset city when state changes
                );
            Navigator.pop(context);
          },
          onClear: () {
            ref.read(searchUIProvider.notifier).state = ref.read(searchUIProvider).copyWith(
                  selectedState: null,
                  selectedCity: null,
                );
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  void _showCityPicker(BuildContext context, WidgetRef ref, String state) {
    final citiesAsync = ref.read(citiesForStateProvider(state));
    citiesAsync.whenData((cities) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => _PickerList(
          title: 'Select City',
          items: cities,
          onSelected: (val) {
            ref.read(searchUIProvider.notifier).state = ref.read(searchUIProvider).copyWith(selectedCity: val);
            Navigator.pop(context);
          },
          onClear: () {
            ref.read(searchUIProvider.notifier).state = ref.read(searchUIProvider).copyWith(selectedCity: null);
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.read(languagesProvider);
    languagesAsync.whenData((langs) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => _PickerList(
          title: 'Select Language',
          items: langs,
          onSelected: (val) {
            ref.read(searchUIProvider.notifier).state = ref.read(searchUIProvider).copyWith(selectedLanguage: val);
            Navigator.pop(context);
          },
          onClear: () {
            ref.read(searchUIProvider.notifier).state = ref.read(searchUIProvider).copyWith(selectedLanguage: null);
            Navigator.pop(context);
          },
        ),
      );
    });
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      backgroundColor: isSelected ? Colors.white : Colors.white10,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _PickerList extends StatelessWidget {
  final String title;
  final List<String> items;
  final Function(String) onSelected;
  final VoidCallback onClear;

  const _PickerList({required this.title, required this.items, required this.onSelected, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(onPressed: onClear, child: const Text('CLEAR', style: TextStyle(color: RFMTheme.primary))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index]),
              onTap: () => onSelected(items[index]),
            ),
          ),
        ),
      ],
    );
  }
}
