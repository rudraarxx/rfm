class Station {
  final String changeuuid;
  final String name;
  final String url;
  final String urlResolved;
  final String? homepage;
  final String? favicon;
  final String? tags;
  final String? country;
  final String? state;
  final String? city;
  final String? language;
  final int? votes;
  final String? frequency;
  final int? bitrate;
  final String? established;
  final String? contactNumber;

  Station({
    required this.changeuuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    this.homepage,
    this.favicon,
    this.tags,
    this.country,
    this.state,
    this.city,
    this.language,
    this.votes,
    this.frequency,
    this.bitrate,
    this.established,
    this.contactNumber,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      changeuuid: json['changeuuid'] ?? '',
      name: json['name'] ?? 'Unknown Station',
      url: json['url'] ?? '',
      urlResolved: json['url_resolved'] ?? json['url'] ?? '',
      homepage: json['homepage'],
      favicon: json['favicon'],
      tags: json['tags'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      language: json['language'],
      votes: json['votes'] is int ? json['votes'] : int.tryParse(json['votes']?.toString() ?? '0'),
      frequency: json['frequency'],
      bitrate: json['bitrate'] is int ? json['bitrate'] : int.tryParse(json['bitrate']?.toString() ?? ''),
      established: json['established']?.toString(),
      contactNumber: json['contact_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'changeuuid': changeuuid,
      'name': name,
      'url': url,
      'url_resolved': urlResolved,
      'homepage': homepage,
      'favicon': favicon,
      'tags': tags,
      'country': country,
      'state': state,
      'city': city,
      'language': language,
      'votes': votes,
      'frequency': frequency,
      'bitrate': bitrate,
      'established': established,
      'contact_number': contactNumber,
    };
  }

  Station copyWith({
    String? changeuuid,
    String? name,
    String? url,
    String? urlResolved,
    String? homepage,
    String? favicon,
    String? tags,
    String? country,
    String? state,
    String? city,
    String? language,
    int? votes,
    String? frequency,
    int? bitrate,
    String? established,
    String? contactNumber,
  }) {
    return Station(
      changeuuid: changeuuid ?? this.changeuuid,
      name: name ?? this.name,
      url: url ?? this.url,
      urlResolved: urlResolved ?? this.urlResolved,
      homepage: homepage ?? this.homepage,
      favicon: favicon ?? this.favicon,
      tags: tags ?? this.tags,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      language: language ?? this.language,
      votes: votes ?? this.votes,
      frequency: frequency ?? this.frequency,
      bitrate: bitrate ?? this.bitrate,
      established: established ?? this.established,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }
}
