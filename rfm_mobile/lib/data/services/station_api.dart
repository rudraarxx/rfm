import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';
import '../models/station.dart';

class StationApi {
  final http.Client _client;

  StationApi({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getStations({
    String? state,
    String? city,
    String? search,
    String? etag,
  }) async {
    final queryParams = <String, String>{};
    if (state != null && state.isNotEmpty) queryParams['state'] = state;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final headers = <String, String>{};
    if (etag != null) headers['If-None-Match'] = etag;

    final uri = Uri.parse('${Env.baseUrl}/stations')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    
    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 304) {
      return {'status': 304};
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch stations: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final stationsJson = data['stations'] as List<dynamic>;
    final stations = stationsJson
        .map((json) => Station.fromJson(json as Map<String, dynamic>))
        .toList();
    
    return {
      'status': 200,
      'stations': stations,
      'etag': response.headers['etag'],
    };
  }

  void dispose() {
    _client.close();
  }
}
