import 'package:abstractwallpapers/FullScreen.dart';
import 'package:abstractwallpapers/about.dart';
import 'package:abstractwallpapers/donate.dart';
import 'package:abstractwallpapers/settings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:abstractwallpapers/MenuItems.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Set status bar color with: Color(0xFF0000FF) also or ->
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.pink,));
  runApp(Abstract());
}

class Abstract extends StatelessWidget {
  static FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: firebaseAnalytics);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Abstract Wallpapers',
        debugShowCheckedModeBanner: false,
        navigatorObservers: <NavigatorObserver>[observer],
        home: Wallpapers(),
        theme: ThemeData(primaryColor: Color.fromRGBO(9, 9, 26, 1.0), cardColor: Color.fromRGBO(9, 9, 26, 1.0)),
      );
}

class Wallpapers extends StatefulWidget {
  @override
  _WallpapersState createState() => _WallpapersState();
}

class _WallpapersState extends State<Wallpapers> {
  static final MobileAdTargetingInfo targetInfo = MobileAdTargetingInfo(
    testDevices: <String>["52161986C14504D2EE7019AAC96D045E"],
    keywords: <String>[
      'WALLPAPERS',
      'WALLS',
      'AMOLED',
      'Clothing',
      'Gaming',
      'Hitman'
    ],
    childDirected: true,
  );

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;


  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> wallpapersList;

  BannerAd createBannerAd() => BannerAd(
      adUnitId: "ca-app-pub-8643344102001837/1267879635",
      size: AdSize.smartBanner,
      targetingInfo: targetInfo,
      listener: (MobileAdEvent event) {
        print("Banner event : $event");
      });

  InterstitialAd createInterstitialAd() => InterstitialAd(
      adUnitId: "ca-app-pub-8643344102001837/7066655742",
      targetingInfo: targetInfo,
      listener: (MobileAdEvent event) {
        print("Banner event : $event");
      });

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: "ca-app-pub-8643344102001837~2641381490");
    _bannerAd = createBannerAd()..load()..show();
    firestore();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    subscription?.cancel();
    super.dispose();
  }

  void firestore() async {
    final Firestore firestore = Firestore();
    await firestore.settings(
        timestampsInSnapshotsEnabled: true, persistenceEnabled: true);
    final CollectionReference collectionReference =
        firestore.collection('abstract');
    subscription = collectionReference
        .orderBy("id", descending: true)
        .snapshots()
        .listen((datasnapshot) =>
            setState(() => wallpapersList = datasnapshot.documents));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Abstract Wallpapers'),
          actions: <Widget>[
            PopupMenuButton<MenuItems>(
              elevation: 5.0,
              onCanceled: () => {},
              tooltip: "Menu",
              onSelected: selectedMenuItem,
              itemBuilder: (BuildContext context) {
                return menu.map((MenuItems menuItem) {
                  return PopupMenuItem<MenuItems>(
                    value: menuItem,
                    child: Text(menuItem.title, style: TextStyle(color: Colors.white),),
                  );
                }).toList();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
            ),
          ],
        ),
        backgroundColor: Color.fromRGBO(9, 9, 26, 1.0),
        body: wallurls(context, wallpapersList),
      );

  void selectedMenuItem(MenuItems menu) {
    switch (menu.id) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => About()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Settings()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Donate()));
        break;
    }
    // if (menu.id == 0) {
    //   Navigator.push(context, MaterialPageRoute(builder: (context) => About()));
    // } else {
    //   if (menu.id == 1) {
    //     Navigator.push(
    //         context, MaterialPageRoute(builder: (context) => Settings()));
    //   }
    // }
  }

  static const List<MenuItems> menu = const <MenuItems>[
    const MenuItems(id: 0, title: 'About'),
    const MenuItems(id: 1, title: 'Settings'),
    const MenuItems(id: 2, title: 'Donate'),
  ];

  Widget wallurls(BuildContext context, List<DocumentSnapshot> wallList) =>
      wallList != null
          ? GridView.count(
              crossAxisCount: 2,
              childAspectRatio: .64,
              children: List.generate(wallList.length, (index) {
                return Container(
                    child: InkWell(
                  onTap: () { 
                    createInterstitialAd()..load()..show();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FullScreen(wallList[index]['url'])));},
                  child: Hero(
                    tag: wallList[index].data['id'],
                    child: FadeInImage(
                      image: NetworkImage(wallList[index].data['url']),
                      fit: BoxFit.cover,
                      placeholder: AssetImage('abstract_placeholder.webp'),
                    ),
                  ),
                ));
              }),
            )
          : Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white),),
            );
}
