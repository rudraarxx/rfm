import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/location_provider.dart';
import '../models/station.dart';
import '../services/station_api.dart';

class StationRepository {
  final StationApi _api;

  StationRepository({StationApi? api}) : _api = api ?? StationApi();

  /// Fetch all stations from the API.
  Future<List<Station>> getStations() async {
    try {
      return await _api.getStations();
    } catch (_) {
      return [];
    }
  }

  /// Fetch stations filtered by [state] and optional [city].
  Future<List<Station>> getStationsByLocation({
    required String state,
    String? city,
  }) async {
    try {
      return await _api.getStations(state: state, city: city);
    } catch (_) {
      return [];
    }
  }

  /// Fetch stations for a specific city.
  Future<List<Station>> getStationsByCity(String city) async {
    try {
      return await _api.getStations(city: city);
    } catch (_) {
      return [];
    }
  }

  /// Search stations by a text query.
  Future<List<Station>> searchStations(String query) async {
    try {
      return await _api.getStations(search: query);
    } catch (_) {
      return [];
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

/// Provider for stations in the current selected city.
/// Watches only [city] — ignores isLoading/error to prevent infinite re-fires.
final cityStationsProvider = FutureProvider<List<Station>>((ref) async {
  // select() ensures we only rebuild when city string actually changes
  final city = ref.watch(locationProvider.select((s) => s.city));
  final repository = ref.read(stationRepositoryProvider);
  return repository.getStationsByCity(city);
});
