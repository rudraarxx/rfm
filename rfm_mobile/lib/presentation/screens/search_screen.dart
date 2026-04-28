import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/rfm_theme.dart';
import '../../data/models/station.dart';
import '../../data/services/station_api.dart';
import '../../logic/controllers/radio_controller.dart';
import '../widgets/station_list_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StationApi _api = StationApi();
  List<Station> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _api.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() => _results = []);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getStations(search: query);
      if (mounted) {
        setState(() {
          _results = data['stations'] as List<Station>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GLOBAL DISCOVERY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: RFMTheme.primary,
                      fontSize: 8,
                      letterSpacing: 3,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search stations, cities, or genres...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
                  prefixIcon: const Icon(LucideIcons.search, color: RFMTheme.primary, size: 20),
                  suffixIcon: _isLoading 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: RFMTheme.primary),
                        ),
                      )
                    : null,
                ),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: _results.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.radio, color: Colors.white.withOpacity(0.05), size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'START YOUR DISCOVERY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.1),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final station = _results[index];
                  return StationListTile(
                    station: station,
                    isActive: ref.watch(radioControllerProvider).currentStation?.changeuuid == station.changeuuid,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(radioControllerProvider.notifier).setStation(station);
                    },
                  );
                },
              ),
        ),
      ],
    );
  }
}
