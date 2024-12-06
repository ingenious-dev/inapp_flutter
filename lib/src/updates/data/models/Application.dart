import './ApplicationVersion.dart';
import './Publisher.dart';

class Application {
  final int id;
  final String name;
  final String identifier;
  final String thumbnail;
  final String description;
  final Publisher? publisher;
  // final int category;
  final bool is_listed;
  final bool is_available;
  final ApplicationVersion? active_version;
  // final List<int> platforms;

  Application({
    required this.id,
    required this.name,
    required this.identifier,
    required this.thumbnail,
    required this.description,
    required this.publisher,
    // required this.category,
    required this.is_listed,
    required this.is_available,
    required this.active_version,
    // required this.platforms,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      name: json['name'],
      identifier: json['identifier'],
      thumbnail: json['thumbnail'],
      description: json['description'],
      publisher: json['publisher'] is Map ? Publisher.fromJson(json['publisher']) : null,
      // category: json['category'],
      is_listed: json['is_listed'],
      is_available: json['is_available'],
      active_version: json['active_version'] is Map ? ApplicationVersion.fromJson(json['active_version']) : null,
      // platforms: json['platforms'],
    );
  }
}