import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('About'),
        ),
        backgroundColor: Color.fromRGBO(9, 9, 26, 1.0),
        body: aboutBody(),
      );
}

Widget aboutBody() => SingleChildScrollView(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 100.0,
                backgroundImage: AssetImage('abstractlogo_forground.webp'),
                backgroundColor: Color.fromRGBO(9, 9, 26, 1.0),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Abstract Wallpapers',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(9, 9, 26, 1.0)),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'This is the abstract wallpapers app all the users waiting for.',
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(9, 9, 26, 1.0)),
              ),
            ],
          ),
        ),
      ),
    );
