import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/persistence_service.dart';

class FavoritesNotifier extends StateNotifier<List<String>> {
  final PersistenceService _persistence = PersistenceService();

  FavoritesNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    state = await _persistence.getFavorites();
  }

  Future<void> toggle(String changeuuid) async {
    if (state.contains(changeuuid)) {
      state = state.where((id) => id != changeuuid).toList();
    } else {
      state = [...state, changeuuid];
    }
    await _persistence.saveFavorites(state);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(),
);
