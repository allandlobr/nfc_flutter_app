import 'dart:convert';

import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/images_page.dart';
import 'screens/login_page.dart';
import 'screens/videos_page.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const severIp = 'http://localhost:8000';
const storage = FlutterSecureStorage();

void main() {
  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
            future: jwtOrEmpty,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.data != "") {
                var str = snapshot.data;
                var jwt = str!.split(".");

                if (jwt.length != 3) {
                  return LoginPage();
                } else {
                  var payload = json.decode(
                      ascii.decode(base64.decode(base64.normalize(jwt[1]))));
                  if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                      .isAfter(DateTime.now())) {
                    return HomePage(str, payload);
                  } else {
                    return LoginPage();
                  }
                }
              } else {
                return LoginPage();
              }
            }),
        '/images': (context) => FutureBuilder(
            future: jwtOrEmpty,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.data != "") {
                var str = snapshot.data;
                var jwt = str!.split(".");

                if (jwt.length != 3) {
                  return LoginPage();
                } else {
                  var payload = json.decode(
                      ascii.decode(base64.decode(base64.normalize(jwt[1]))));
                  if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                      .isAfter(DateTime.now())) {
                    return ImagesPage(str, payload);
                  } else {
                    return LoginPage();
                  }
                }
              } else {
                return LoginPage();
              }
            }),
        '/videos': (context) => FutureBuilder(
            future: jwtOrEmpty,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.data != "") {
                var str = snapshot.data;
                var jwt = str!.split(".");

                if (jwt.length != 3) {
                  return LoginPage();
                } else {
                  var payload = json.decode(
                      ascii.decode(base64.decode(base64.normalize(jwt[1]))));
                  if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                      .isAfter(DateTime.now())) {
                    return VideosPage(str, payload);
                  } else {
                    return LoginPage();
                  }
                }
              } else {
                return LoginPage();
              }
            }),
      },
    );
  }
}
