import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/env.dart';
import '../models/station.dart';
import 'favorites_controller.dart';

final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>((ref) {
  return SyncController(ref);
});

class SyncState {
  final String? syncId;
  final bool isSyncing;
  final String? error;

  SyncState({this.syncId, this.isSyncing = false, this.error});

  SyncState copyWith({String? syncId, bool? isSyncing, String? error}) {
    return SyncState(
      syncId: syncId ?? this.syncId,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
    );
  }
}

class SyncController extends StateNotifier<SyncState> {
  final Ref _ref;
  SyncController(this._ref) : super(SyncState()) {
    _loadSyncId();
  }

  static const String _storageKey = 'rfm_sync_id';

  Future<void> _loadSyncId() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(syncId: prefs.getString(_storageKey));
  }

  Future<void> setSyncId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, id);
    state = state.copyWith(syncId: id);
    pull();
  }

  Future<void> push() async {
    if (state.syncId == null) return;
    
    state = state.copyWith(isSyncing: true);
    try {
      final favorites = _ref.read(favoritesControllerProvider);
      final response = await http.post(
        Uri.parse('${Env.baseUrl}/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': state.syncId,
          'favorites': favorites.map((s) => s.toJson()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        state = state.copyWith(isSyncing: false, error: 'Push failed');
      } else {
        state = state.copyWith(isSyncing: false);
      }
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  Future<void> pull() async {
    if (state.syncId == null) return;

    state = state.copyWith(isSyncing: true);
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/sync?id=${state.syncId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favsJson = data['favorites'] ?? [];
        final List<Station> remoteFavs = favsJson.map((j) => Station.fromJson(j)).toList();
        
        // Update local favorites
        final notifier = _ref.read(favoritesControllerProvider.notifier);
        // We need a method to replace all favorites
        notifier.replaceFavorites(remoteFavs);
        
        state = state.copyWith(isSyncing: false);
      } else {
        state = state.copyWith(isSyncing: false, error: 'Pull failed');
      }
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }
}
