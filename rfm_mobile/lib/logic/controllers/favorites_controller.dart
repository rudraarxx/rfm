import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/station.dart';

final favoritesControllerProvider = StateNotifierProvider<FavoritesController, List<Station>>((ref) {
  return FavoritesController();
});

class FavoritesController extends StateNotifier<List<Station>> {
  FavoritesController() : super([]) {
    _loadFavorites();
  }

  static const String _storageKey = 'rfm_favorites';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_storageKey);
    
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      state = decoded.map((item) => Station.fromJson(item)).toList();
    }
  }

  Future<void> toggleFavorite(Station station) async {
    final isFav = state.any((s) => s.changeuuid == station.changeuuid);
    
    if (isFav) {
      state = state.where((s) => s.changeuuid != station.changeuuid).toList();
    } else {
      state = [...state, station];
    }

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(state.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  bool isFavorite(Station station) {
    return state.any((s) => s.changeuuid == station.changeuuid);
  }
}
