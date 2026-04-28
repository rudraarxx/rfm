import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/stations.dart';
import '../models/station.dart';
import '../services/station_api.dart';

import '../repositories/persistence_service.dart';

class StationRepository {
  final StationApi _api;
  final PersistenceService _persistence;

  StationRepository({StationApi? api, PersistenceService? persistence}) 
      : _api = api ?? StationApi(),
        _persistence = persistence ?? PersistenceService();

  Future<List<Station>> getStations() async {
    try {
      // 1. Load from local cache first
      final (cached, etag) = await _persistence.getStationsCache();
      
      // 2. Fetch from API with ETag
      final response = await _api.getStations(etag: etag);
      
      if (response['status'] == 304) {
        return cached ?? fallbackStations;
      }
      
      if (response['status'] == 200) {
        final stations = response['stations'] as List<Station>;
        final newEtag = response['etag'] as String?;
        if (newEtag != null) {
          await _persistence.saveStationsCache(stations, newEtag);
        }
        return stations;
      }
    } catch (e) {
      // API unavailable — try returning cache before falling back to bundled
      final (cached, _) = await _persistence.getStationsCache();
      if (cached != null) return cached;
    }
    return fallbackStations;
  }
}

final stationRepositoryProvider = Provider((ref) => StationRepository());

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repository = ref.watch(stationRepositoryProvider);
  return repository.getStations();
});
