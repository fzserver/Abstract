import 'package:http/http.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class FullScreen extends StatefulWidget {
  final String imgPath;
  FullScreen(this.imgPath);

  @override
  FullScreenState createState() => new FullScreenState();
}

class FullScreenState extends State<FullScreen>
    with SingleTickerProviderStateMixin {
  bool downloading = false;
  var progress = "";
  PermissionGroup permission1 = PermissionGroup.storage;
  static final Random random = Random();
  // FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> downloadFile(String imgUrl) async {
    Dio dio = Dio();
    bool checkPermission1;
    final List<PermissionGroup> permissions = <PermissionGroup>[permission1];
    await PermissionHandler()
        .checkPermissionStatus(permission1)
        .then((PermissionStatus status) {
      setState(() {
        if (status == PermissionStatus.denied) {
          checkPermission1 = false;
        } else {
          if (status == PermissionStatus.granted) {
            checkPermission1 = true;
          }
        }
      });
    });
    // print(checkPermission1);
    if (checkPermission1 == false) {
      await PermissionHandler().requestPermissions(permissions);
      await PermissionHandler()
          .checkPermissionStatus(permission1)
          .then((PermissionStatus status) {
        setState(() {
          if (status == PermissionStatus.denied) {
            checkPermission1 = false;
          } else {
            if (status == PermissionStatus.granted) {
              checkPermission1 = true;
            }
          }
        });
      });
    }
    if (checkPermission1 == true) {
      var dir = await getExternalStorageDirectory();
      var dirloc = "${dir.path}/Abstract/";
      var randid = random.nextInt(10000);

      try {
        FileUtils.mkdir([dirloc]);
        await dio.download(imgUrl, dirloc + randid.toString() + ".jpg",
            onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            downloading = true;
            progress =
                ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
          });
        });
      } catch (e) {
        print(e);
      }

      setState(() {
        progress = "Download Completed.";
        Fluttertoast.showToast(
            msg: 'Image Saved to Gallery.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 5,
            backgroundColor: Colors.white70,
            textColor: Color.fromRGBO(9, 9, 26, 1.0),
            fontSize: 18.0);
        downloading = false;
      });
    } else {
      setState(() {
        progress = "Permission Denied!";
      });
    }
  }

  setwallpaper(String imgUrl) async {
    await Wallpaper.homeScreen(imgUrl);
    if (!mounted) return;
    setState(() {
      Fluttertoast.showToast(
          msg: 'Wallpaper Set Successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 5,
          backgroundColor: Colors.white70,
          textColor: Color.fromRGBO(9, 9, 26, 1.0),
          fontSize: 18.0);
    });
  }

  shareImg(String imgUrl) async {
    try {
      var request = await HttpClient().getUrl(Uri.parse(imgUrl));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file('Abstract Wallpaper', 'abs.jpg', bytes, 'image/jpg');
    } catch (error) {
      print('Error Sharing Image: $error');
    }
  }

  final LinearGradient backgroundGradient = LinearGradient(
      colors: [Color(0x10000000), Color(0x30000000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: downloading
              ? Container(
                  decoration: BoxDecoration(gradient: backgroundGradient),
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Hero(
                          tag: widget.imgPath,
                          child: FadeInImage(
                            image: NetworkImage(widget.imgPath),
                            fit: BoxFit.cover,
                            placeholder:
                                AssetImage('abstract_placeholder.webp'),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          color: Colors.black45,
                          width: double.infinity,
                          height: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.pink),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                'Downloaded: $progress',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(gradient: backgroundGradient),
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Hero(
                          tag: widget.imgPath,
                          child: FadeInImage(
                            image: NetworkImage(widget.imgPath),
                            fit: BoxFit.cover,
                            placeholder:
                                AssetImage('abstract_placeholder.webp'),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AppBar(
                              elevation: 0.0,
                              backgroundColor: Colors.transparent,
                              leading: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              actions: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => shareImg(widget.imgPath),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  height: 50.0,
                                  child: MaterialButton(
                                    elevation: 20.0,
                                    splashColor: Colors.black,
                                    color: Colors.black45,
                                    textColor: Colors.white,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    child: Text('DOWNLOAD IMAGE'),
                                    onPressed: () =>
                                        downloadFile(widget.imgPath),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  height: 50.0,
                                  child: MaterialButton(
                                    elevation: 20.0,
                                    splashColor: Colors.black,
                                    color: Colors.black45,
                                    textColor: Colors.white,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    child: Text('SET WALLPAPER'),
                                    onPressed: () =>
                                        setwallpaper(widget.imgPath),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 50.0),
                            ),
                          ],
                        ),

                        // child: Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: <Widget>[
                        //     MaterialButton(
                        //       elevation: 20.0,
                        //       splashColor: Colors.black,
                        //       color: Colors.black45,
                        //       textColor: Colors.white,
                        //       height: 50.0,
                        //       minWidth: double.infinity,
                        //       child: Text('DOWNLOAD IMAGE'),
                        //       onPressed: () => downloadFile(widget.imgPath),
                        //     ),
                        //     Padding(
                        //       padding: EdgeInsets.only(bottom: 50.0),
                        //     ),
                        //   ],
                        // ),
                      ),
                    ],
                  ),
                ),
        ),
      );
}
