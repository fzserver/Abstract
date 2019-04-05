import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String version = "";

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      backgroundColor: Color.fromRGBO(9, 9, 26, 1.0),
      body: settingsBody(version));
}

ListView settingsBody(String version) => ListView(
      children: <Widget>[
        ListTile(
            leading: Icon(Icons.info, color: Colors.white,),
            title: Text(
              'Version',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text('$version',
            style: TextStyle(color: Colors.white54,))),
        ListTile(
          leading: Icon(Icons.shop, color: Colors.white,),
          title: Text('Rate on Google Play', style: TextStyle(color: Colors.white),),
          onTap: () => LaunchReview.launch(),
        ),
        ListTile(
          leading: Icon(Icons.security, color: Colors.white,),
          title: Text('Privacy Policy', style: TextStyle(color: Colors.white),),
          onTap: () => _launchURL(),
        ),
      ],
    );

_launchURL() async {
  const url = 'https://firebasestorage.googleapis.com/v0/b/wallpapers-65988.appspot.com/o/abstract%2Fprivacy_policy.html?alt=media&token=4ed8eb6d-8155-41e8-8d3b-ebc0a3a7d728';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
