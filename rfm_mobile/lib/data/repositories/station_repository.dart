import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/stations.dart';
import '../models/station.dart';

class StationRepository {
  Future<List<Station>> getStations() async {
    // For now, we return fallback stations. 
    // Later we can add Radio Browser API integration.
    await Future.delayed(const Duration(milliseconds: 500));
    return fallbackStations;
  }
}

final stationRepositoryProvider = Provider((ref) => StationRepository());

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repository = ref.watch(stationRepositoryProvider);
  return repository.getStations();
});
