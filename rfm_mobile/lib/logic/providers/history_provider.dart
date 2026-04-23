import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/station.dart';
import '../../data/repositories/persistence_service.dart';

class HistoryNotifier extends StateNotifier<List<Station>> {
  final PersistenceService _persistence = PersistenceService();
  static const int _maxHistory = 20;

  HistoryNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    state = await _persistence.getHistory();
  }

  Future<void> add(Station station) async {
    // Remove existing entry for same station to avoid duplicates
    final updated = state.where((s) => s.changeuuid != station.changeuuid).toList();
    // Prepend most recent, cap at max
    state = [station, ...updated].take(_maxHistory).toList();
    await _persistence.saveHistory(state);
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<Station>>(
  (ref) => HistoryNotifier(),
);
