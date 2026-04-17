import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';
import '../models/station.dart';

class StationApi {
  final http.Client _client;

  StationApi({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch stations from MongoDB via the Next.js API.
  /// Supports optional [state], [city], and [search] filters.
  Future<List<Station>> getStations({
    String? state,
    String? city,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (state != null && state.isNotEmpty) queryParams['state'] = state;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('${Env.baseUrl}/stations')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
        
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch stations: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final stationsJson = data['stations'] as List<dynamic>;
    return stationsJson
        .map((json) => Station.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the state/city index for discovery dropdowns.
  /// Returns a map where keys are "State|City" strings.
  Future<Map<String, List<String>>> getIndex() async {
    final uri = Uri.parse('${Env.baseUrl}/index');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch index: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(
      key,
      (value as List<dynamic>).map((e) => e.toString()).toList(),
    ));
  }

  /// Get list of unique states from the index.
  Future<List<String>> getStates() async {
    final index = await getIndex();
    final states = <String>{};
    for (final key in index.keys) {
      final parts = key.split('|');
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        states.add(parts[0]);
      }
    }
    final sorted = states.toList()..sort();
    return sorted;
  }

  /// Get list of cities for a given [state] from the index.
  Future<List<String>> getCitiesForState(String state) async {
    final index = await getIndex();
    final cities = <String>{};
    for (final key in index.keys) {
      final parts = key.split('|');
      if (parts.length == 2 && parts[0] == state && parts[1].isNotEmpty) {
        cities.add(parts[1]);
      }
    }
    final sorted = cities.toList()..sort();
    return sorted;
  }

  void dispose() {
    _client.close();
  }
}
