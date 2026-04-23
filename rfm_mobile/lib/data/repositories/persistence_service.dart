import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';

class PersistenceService {
  static const String _keyStation = 'current_station';
  static const String _keyVolume = 'volume';
  static const String _keyVisualizerStyle = 'visualizer_style';
  static const String _keyFavorites = 'favorites';
  static const String _keyHistory = 'history';

  Future<void> saveStation(Station station) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStation, jsonEncode(station.toJson()));
  }

  Future<Station?> getStation() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyStation);
    if (data == null) return null;
    try {
      return Station.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyVolume, volume);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyVolume) ?? 1.0;
  }

  Future<void> saveVisualizerStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVisualizerStyle, style);
  }

  Future<String> getVisualizerStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVisualizerStyle) ?? 'classic';
  }

  Future<void> saveFavorites(List<String> uuids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavorites, jsonEncode(uuids));
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyFavorites);
    if (data == null) return [];
    try {
      return List<String>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHistory(List<Station> stations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHistory, jsonEncode(stations.map((s) => s.toJson()).toList()));
  }

  Future<List<Station>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyHistory);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List).map((e) => Station.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
