import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';

class PersistenceService {
  static const String _keyStation = 'current_station';
  static const String _keyVolume = 'volume';
  static const String _keyVisualizerStyle = 'visualizer_style';
  static const String _keyStationsCache = 'stations_cache';
  static const String _keyStationsEtag = 'stations_etag';

  Future<void> saveStationsCache(List<Station> stations, String etag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStationsCache, jsonEncode(stations.map((s) => s.toJson()).toList()));
    await prefs.setString(_keyStationsEtag, etag);
  }

  Future<(List<Station>?, String?)> getStationsCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyStationsCache);
    final etag = prefs.getString(_keyStationsEtag);
    if (data == null) return (null, null);
    try {
      final List<dynamic> json = jsonDecode(data);
      final stations = json.map((s) => Station.fromJson(s as Map<String, dynamic>)).toList();
      return (stations, etag);
    } catch (e) {
      return (null, null);
    }
  }

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
}
