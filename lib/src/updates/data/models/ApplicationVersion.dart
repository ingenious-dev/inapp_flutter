import './Application.dart';

class ApplicationVersion {
  final int id;
  final Application? application;
  final String version;
  final String release_notes;
  final String? thumbnail;
  // final List<int> images;
  final String description;
  final bool contains_ad;
  final int downloads;
  // <<<<<>>>>>>
  // TODO DEPRECATION NOTICE (2024.08.26)
  // final int platform;
  // final String? file;
  // final String download_link;
  // final double? size_in_mbs;
  // <<<<<>>>>>>
  // final int author;
  final String date_posted;
  final bool is_available;
  final ApplicationVersion? next_version;

  final bool is_demo;
  final DateTime? demo_date_start;
  final DateTime? demo_date_end;

  ApplicationVersion({
    required this.id,
    required this.application,
    required this.version,
    required this.release_notes,
    required this.thumbnail,
    // required this.images,
    required this.description,
    required this.contains_ad,
    required this.downloads,
    // required this.platform,
    // required this.file,
    // required this.download_link,
    // required this.size_in_mbs,
    // required this.author,
    required this.date_posted,
    required this.is_available,
    required this.next_version,

    required this.is_demo,
    required this.demo_date_start,
    required this.demo_date_end,
  });

  factory ApplicationVersion.fromJson(Map<String, dynamic> json) {
    return ApplicationVersion(
      id: json['id'],
      application: json['application'] is Map ? Application.fromJson(json['application']) : null,
      version: json['version'],
      release_notes: json['release_notes'],
      thumbnail: json['thumbnail'],
      // images: json['images'],
      description: json['description'],
      contains_ad: json['contains_ad'],
      downloads: json['downloads'],
      // platform: json['platform'],
      // file: json['file'],
      // download_link: json['download_link'],
      // size_in_mbs: json['size_in_mbs'],
      // author: json['author'],
      date_posted: json['date_posted'],
      is_available: json['is_available'],
      next_version: json['next_version'] is Map ? ApplicationVersion.fromJson(json['next_version']) : null,

      is_demo: json['is_demo'],
      demo_date_start: json['demo_date_start'] != null ? DateTime.parse(json['demo_date_start']).toLocal() : null,
      demo_date_end: json['demo_date_end'] != null ? DateTime.parse(json['demo_date_end']).toLocal() : null,
    );
  }
}