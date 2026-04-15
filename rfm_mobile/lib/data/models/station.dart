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
  final int? votes;

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
    this.votes,
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
      votes: json['votes'] is int ? json['votes'] : int.tryParse(json['votes']?.toString() ?? '0'),
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
      'votes': votes,
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
    int? votes,
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
      votes: votes ?? this.votes,
    );
  }
}
