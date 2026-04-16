import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/stations.dart';
import '../models/station.dart';
import '../services/station_api.dart';

class StationRepository {
  final StationApi _api;

  StationRepository({StationApi? api}) : _api = api ?? StationApi();

  /// Fetch all stations from the API, falling back to hardcoded stations on failure.
  Future<List<Station>> getStations() async {
    try {
      final stations = await _api.getStations();
      if (stations.isNotEmpty) return stations;
    } catch (_) {
      // API unavailable — fall back to bundled stations
    }
    return fallbackStations;
  }

  /// Fetch stations filtered by [state] and optional [city].
  Future<List<Station>> getStationsByLocation({
    required String state,
    String? city,
  }) async {
    try {
      return await _api.getStations(state: state, city: city);
    } catch (_) {
      // Filter fallback stations by state
      return fallbackStations
          .where((s) => s.state?.toLowerCase() == state.toLowerCase())
          .toList();
    }
  }

  /// Search stations by a text query.
  Future<List<Station>> searchStations(String query) async {
    try {
      return await _api.getStations(search: query);
    } catch (_) {
      final q = query.toLowerCase();
      return fallbackStations
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              (s.tags?.toLowerCase().contains(q) ?? false))
          .toList();
    }
  }

  /// Fetch the state/city discovery index.
  Future<List<String>> getStates() async {
    try {
      return await _api.getStates();
    } catch (_) {
      return [];
    }
  }

  /// Fetch cities for a given state.
  Future<List<String>> getCitiesForState(String state) async {
    try {
      return await _api.getCitiesForState(state);
    } catch (_) {
      return [];
    }
  }
}

final stationRepositoryProvider = Provider((ref) => StationRepository());

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repository = ref.watch(stationRepositoryProvider);
  return repository.getStations();
});

/// Provider for stations filtered by state and city.
final locationStationsProvider = FutureProvider.family<List<Station>, ({String state, String? city})>(
  (ref, params) async {
    final repository = ref.watch(stationRepositoryProvider);
    return repository.getStationsByLocation(state: params.state, city: params.city);
  },
);

/// Provider for search results.
final searchStationsProvider = FutureProvider.family<List<Station>, String>(
  (ref, query) async {
    final repository = ref.watch(stationRepositoryProvider);
    return repository.searchStations(query);
  },
);
