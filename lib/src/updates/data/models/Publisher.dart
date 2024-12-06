class Publisher {
  final int id;
  final String name;
  final String website;
  final String? logo;

  Publisher({
    required this.id,
    required this.name,
    required this.website,
    required this.logo,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['id'],
      name: json['name'],
      website: json['website'],
      logo: json['logo'],
    );
  }
}