import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import './presentation/pages/update_page.dart';
import './data/models/ApplicationVersion.dart';
import 'data/datasources/application_version_data_source.dart';
import './data/datasources/local_storage_data_source.dart';
import '../core/utilities/error_helpers.dart';
import '../core/utilities/custom_snackbar.dart';
// import '../../core/platform/app_strings.dart';

Future syncAppDetails(BuildContext context, String identifier) async {
  // TODO https://pub.dev/packages/package_info_plus#usage
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  
  // String appName = packageInfo.appName;
  // String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  // String buildNumber = packageInfo.buildNumber;

  // String identifier = AppStrings.applicationIdentifier;
  // String app_version = AppStrings.applicationVersion;
  // String app_version = '$version($buildNumber)';
  String app_version = version;

  try {
    // Missing Information
    List<ApplicationVersion> application_versions = await fetchApplicationVersions(dev_identifier: identifier, version: app_version);
    if(application_versions.isEmpty) {
      if(context.mounted) {
        // TODO https://stackoverflow.com/questions/45889341/flutter-remove-all-routes/57233955#57233955
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          UpdatePage(applicationIdentifier: identifier, current_version: null, is_unknown: true)), (Route<dynamic> route) => false);
      } else {
        throw 'This version could not be verified';
      }
      
      return;
    }

    final version = application_versions.first;

     // New Version not available, Old version not available
    if (version.next_version == null && !version.is_available) {
      if(context.mounted) {
        // TODO https://stackoverflow.com/questions/45889341/flutter-remove-all-routes/57233955#57233955
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          UpdatePage(applicationIdentifier: identifier, in_maintenance: true, current_version: version,)), (Route<dynamic> route) => false);
      } else {
        throw 'The application is currently in maintance mode. Please try again later.\n\nYou can also contact us for assistance.\nWe apolgize for any incovenience';
      }

      return;
    }

    // New Version Available, Old version still available
    if (version.next_version != null && version.is_available) {
      if(context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
          UpdatePage(
            applicationIdentifier: identifier,
            application: version.application,
            publisher: version.application?.publisher,
            next_version: version.next_version,
            current_version: version,
            is_updated: true
          )));
      } else {
        throw "You'll need to update to the latest version before you can use the app";
      }
      
      return;
    }
    
    // New Version Available, Old version discontinued
    if (version.next_version != null && !version.is_available) {
      if(context.mounted) {
        // TODO https://stackoverflow.com/questions/45889341/flutter-remove-all-routes/57233955#57233955
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          UpdatePage(
            applicationIdentifier: identifier,
            application: version.application,
            publisher: version.application?.publisher,
            next_version: version.next_version,
            current_version: version,
          )), (Route<dynamic> route) => false);
      } else {
        throw "You'll need to update to the latest version before you can use the app";
      }
      
      return;
    }

    if (version.is_demo || version.demo_date_start != null) {
      // If demo is forced or demo end date has not arrived, decide wether to show prompt
      if(version.is_demo || version.demo_date_end != null && version.demo_date_end!.isAfter(DateTime.now())) {

        String? last_demo_prompt = await localStorage.getData('last_demo_prompt');
        if (last_demo_prompt?.isNotEmpty ?? false) {
          DateTime last_date = DateTime.parse(last_demo_prompt!);
          // print(last_date.difference(DateTime.now()).inHours);
          if(last_date.difference(DateTime.now()).inHours < 24) {
            // Do not show prompt if it has been less than 24 hours since it was last shown
            return;
          }
        }
      }

      if(context.mounted) {
        // TODO https://stackoverflow.com/questions/45889341/flutter-remove-all-routes/57233955#57233955
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          UpdatePage(
            applicationIdentifier: identifier,
            application: version.application,
            publisher: version.application?.publisher,
            next_version: version.next_version,
            current_version: version,
            is_demo: true,
          )), (Route<dynamic> route) => false);
      } else {
        throw "This is a demo application for ${version.application?.name}.";
      }
      await localStorage.storeData('last_demo_prompt', DateTime.now().toString());

      return;
    }

  } catch (e) {
    if(context.mounted) {
      // show snackbar
      showCustomSnackBar(
        context: context,
        message: getErrorMessage(e),
        color: Colors.red,
      );
      return;
    } else {
      showCustomSnackBar(
        context: context,
        message: getErrorMessage(e),
        color: Colors.red,
      );
    }
  }
}