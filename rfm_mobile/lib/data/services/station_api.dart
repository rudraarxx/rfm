import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';
import '../models/station.dart';

class StationApi {
  final http.Client _client;

  StationApi({http.Client? client}) : _client = client ?? http.Client();

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

  void dispose() {
    _client.close();
  }
}
