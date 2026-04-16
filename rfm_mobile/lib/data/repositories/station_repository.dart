import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/stations.dart';
import '../models/station.dart';
import '../services/station_api.dart';

class StationRepository {
  final StationApi _api;

  StationRepository({StationApi? api}) : _api = api ?? StationApi();

  Future<List<Station>> getStations() async {
    try {
      final stations = await _api.getStations();
      if (stations.isNotEmpty) return stations;
    } catch (_) {
      // API unavailable — fall back to bundled stations
    }
    return fallbackStations;
  }
}

final stationRepositoryProvider = Provider((ref) => StationRepository());

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repository = ref.watch(stationRepositoryProvider);
  return repository.getStations();
});
