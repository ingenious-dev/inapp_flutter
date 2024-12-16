import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../widgets/bootstrap_button.dart';
import '../../../core/platform/color_palette.dart';
import '../../data/models/Application.dart';
import '../../data/models/ApplicationVersion.dart';
import '../../data/models/Publisher.dart';
// import '../../../../core/platform/app_strings.dart';
import '../../../core/network/network_info.dart';
import '../../../core/utilities/error_helpers.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage({super.key, required this.applicationIdentifier, this.application, this.publisher, this.next_version, this.in_maintenance = false,
    required this.current_version, this.is_unknown = false, this.is_updated = false, this.is_demo = false});

  String applicationIdentifier;
  Application? application;
  Publisher? publisher;
  ApplicationVersion? next_version;
  bool in_maintenance;

  ApplicationVersion? current_version;
  bool is_unknown;
  bool is_updated;
  bool is_demo;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool _isLoading = false;

  Application? application;
  Publisher? publisher;
  ApplicationVersion? current_version;
  ApplicationVersion? next_version;

  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  Map<String, dynamic> _packageData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();

    application = widget.application;
    publisher = widget.publisher;
    current_version = widget.current_version;
    next_version = widget.next_version;
    initPlatformState();
    initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 80,),

                    publisher?.logo != null
                    ? Container(
                      color: Color(0xFFB7CBE7),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Image.network(publisher!.logo!, height:200, width: 200,),
                    )
                    : current_version?.application?.thumbnail != null
                      ? Image.network(current_version!.application!.thumbnail, height:200, width: 200,)
                      : Image.asset("assets/Logo/APP_ICON_BLACK.png", height:200, width: 200,),
                    SizedBox(height: 20,),

                    // widget.in_maintenance
                    // ? _buildMaintance()
                    // : application_version != null
                    //   ? _buildUpdate()
                    //   : _buildUnknown(),

                    widget.is_unknown ? _buildUnknown() : Container(),
                    widget.in_maintenance ? _buildMaintance() : Container(),
                    widget.is_updated ? _buildUpdate() : Container(),
                    widget.is_demo ? _buildDemo() : Container(),
                    
                  ],
                ),
              ),
              _buildButtons()
            ],
          ),
        ),
      )
    );
  }

  Widget _buildMaintance() {
    return Column(
      children: [
        Text("Maintenance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        SizedBox(height: 20,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("The application is currently in maintance mode. Please try again later.\n\nYou can also contact us for assistance.\nWe apolgize for any incovenience",
            style: TextStyle(fontSize: 17), textAlign: TextAlign.center,),
        ),
        SizedBox(height: 10,),
        GestureDetector(
          onTap: _contactUs,
          child: Text("Contact Us", style: TextStyle(color: ColorPalette.blue, fontSize: 12),)
        )
      ],
    );
  }

  Widget _buildUpdate() {    
    return Column(
      children: [
        Text("Update ${application?.name}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        SizedBox(height: 20,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("You'll need to update to the latest version before you can use the app",
            style: TextStyle(fontSize: 17), textAlign: TextAlign.center,),
        ),
        SizedBox(height: 10,),
        GestureDetector(
          onTap: _showDetails,
          child: Text("View details", style: TextStyle(color: ColorPalette.blue, fontSize: 12),)
        )
      ],
    );
  }

  Widget _buildDemo() {
    // bool demo_started = current_version!.is_demo || (current_version!.demo_date_start?.isBefore(DateTime.now()) ?? false);
    bool demo_ended = !current_version!.is_demo && (current_version!.demo_date_end?.isBefore(DateTime.now()) ?? false);
    bool is_timed = !current_version!.is_demo && current_version!.demo_date_start != null;

    return Column(
      children: [
        Text("Demo application", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        SizedBox(height: 20,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(is_timed
            ? "This is a demo application for ${application?.name}.\n\nIt is active from ${DateFormat("EEE, MMM d, yyyy H:mm").format(current_version!.demo_date_start!)}\n to ${DateFormat("EEE, MMM d, yyyy H:mm").format(current_version!.demo_date_end!)}"
            : "This is a demo application for ${application?.name}.",
            style: TextStyle(fontSize: 17), textAlign: TextAlign.center,),
        ),
        SizedBox(height: 10,),
        demo_ended
        ? BootstrapButton(text: "Contact Us", type: "success", isLoading: _isLoading, onPressed: () {
          _contactUs();
        })
        : BootstrapButton(text: "Ok", type: "success", isLoading: _isLoading, onPressed: () {
          Navigator.pop(context);
        })
      ],
    );
  }

  Widget _buildUnknown() {
    String versionAndBuild = _packageData["version"] ?? "-";
    // versionAndBuild += '(${_packageData["buildNumber"] ?? "-"})';

    return Column(
      children: [
        Text("Missing information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        SizedBox(height: 20,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("This version could not be verified",
            style: TextStyle(fontSize: 17), textAlign: TextAlign.center,),
        ),
        SizedBox(height: 10,),
        Text(versionAndBuild, style: TextStyle(color: ColorPalette.blue, fontSize: 12),)
      ],
    );
  }

  Widget _buildButtons() {
    return next_version != null
      ? BootstrapButton(text: "Update", type: "primary", isLoading: _isLoading, onPressed: () {
        _openUrl('');
      })
      : BootstrapButton(text: "Visit Store", type: "primary", isLoading: _isLoading, onPressed: () {
        _openUrl('');
      });
  }

  _openUrl(String url) async {
    final Uri _url = Uri.parse('$APP_STORE_BASE_URL/app_store/apps/${current_version?.application?.identifier ?? ''}');
    try {
      if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $_url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getErrorMessage(e)),
        ),
      );
    }
  }

  _showDetails() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: Text("Product details", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(color: Colors.black.withOpacity(0.2), height: 0,),
            ),
            ListTile(
              title: Text("Version"),
              subtitle: Text(next_version?.version ?? '-'),
            ),
            // ! TO BE DONE - Figure out how to get 'size_in_mbs' from ApplicationBuild
            // ListTile(
            //   title: Text("Size"),
            //   subtitle: Text("${next_version?.size_in_mbs ?? '-'} MB"),
            // ),

            publisher?.logo != null
            ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("from", style: TextStyle(color: Colors.grey, fontSize: 12),),
                  // Image.asset("assets/images/ingenious logo - cropped.png", height:20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    color: Color(0xFFB7CBE7),
                    child: Image.network(publisher!.logo!, height:20),
                  ),
                ],
              ),
            )
            : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("from ${publisher?.name}", style: TextStyle(color: Colors.grey, fontSize: 12),),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData =
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      // <<<<<<<<<>>>>>>>>
      // ! TO BE DONE - investigate
      // Was available in device_info_plus: ^8.2.2
      // but not in device_info_plus: ^11.2.0 (maybe deprecation or API refactored)
      // 'displaySizeInches':
      //     ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      // 'displayWidthPixels': build.displayMetrics.widthPx,
      // 'displayWidthInches': build.displayMetrics.widthInches,
      // 'displayHeightPixels': build.displayMetrics.heightPx,
      // 'displayHeightInches': build.displayMetrics.heightInches,
      // 'displayXDpi': build.displayMetrics.xDpi,
      // 'displayYDpi': build.displayMetrics.yDpi,
      // <<<<<<<<<>>>>>>>>
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

  initPackageInfo() async {
    // TODO https://pub.dev/packages/package_info_plus#usage
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    // String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;

    _packageData = {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };

    setState(() {
      
    });
  }
  
  _contactUs() async {
    String appName = _packageData["appName"];
    String packageName = _packageData["packageName"];
    String version = _packageData["version"];
    String buildNumber = _packageData["buildNumber"];

    String device = '';
    String os = '';
    String os_version = '';
    if (Platform.isAndroid) {
      device = '${_deviceData['manufacturer']} ${_deviceData['device']}';
      os = 'Android';
      os_version = _deviceData['version.release'];
    } else if (Platform.isIOS) {
      device = _deviceData['name'];
      os = 'iOS';
      os_version = _deviceData['systemVersion'];
    } else if (Platform.isLinux) {
      os = 'Linux';
    } else if (Platform.isMacOS) {
      os = 'MacOS';
    } else if (Platform.isWindows) {
      os = 'Windows';
    }

    // TODO https://pub.dev/packages/flutter_email_sender#example
    final Email email = Email(
      // body: 'Email body',
      body: """


$appName $os Version $version ($buildNumber)
Device: $device
$os $os_version
Locale: ${Intl.getCurrentLocale()}""",
      subject: "$os Support",
      recipients: [
        // 'example@example.com'
        'support@ingenious.or.ke'
      ],
      // cc: ['cc@example.com'],
      // bcc: ['bcc@example.com'],
      // attachmentPaths: ['/path/to/attachment.zip'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

}