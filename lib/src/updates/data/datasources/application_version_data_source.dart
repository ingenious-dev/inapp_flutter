import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ApplicationVersion.dart';
import '../../../core/network/network_info.dart';

Future<List<ApplicationVersion>> fetchApplicationVersions({String? dev_identifier, String? version, int? page}) async {
  String query = dev_identifier == null ? '' : 'dev_identifier=$dev_identifier';
  query += version == null ? '' : '&version=$version';
  query += page == null ? '' : '&page=$page';
  query = "?$query";
  
  final response = await http
      // .get(Uri.parse('https://ie-vps-citizen.ingenious.or.ke/vps/api/v0/countries'));
      .get(Uri.parse('$APP_STORE_BASE_URL/app_store/api/open/application-versions/$query'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return (jsonDecode(response.body)['results'] as List)
      .map((e) => ApplicationVersion.fromJson(e))
      .toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load application versions');
  }
}

Future<ApplicationVersion> getApplicationVersion(int id) async {
  final response = await http
      // .get(Uri.parse('https://ie-vps-citizen.ingenious.or.ke/vps/api/v0/countries'));
      .get(Uri.parse('$APP_STORE_BASE_URL/app_store/api/open/application-versions/$id/'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return ApplicationVersion.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load application version');
  }
}

Future<ApplicationVersion> updateApplicationVersion(int id, Map<String, dynamic> profile) async {
  final response = await http.put(
    Uri.parse('$APP_STORE_BASE_URL/app_store/api/open/application-versions/$id/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(profile),
  );

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return ApplicationVersion.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to update application version.');
  }
}