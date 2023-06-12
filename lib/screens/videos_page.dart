import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as camera;
import 'package:solinski_app_flutter/screens/login_page.dart';

import '../video_widget.dart';
import './video_camera_page.dart';

const serverIp = 'http://localhost:8000';
const storage = FlutterSecureStorage();

class VideosPage extends StatefulWidget {
  const VideosPage(this.jwt, this.payload, {super.key});

  factory VideosPage.fromBase64(String jwt) => VideosPage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  VideosPageState createState() => VideosPageState();
}

class VideosPageState extends State<VideosPage> {
  int _selectedIndex = 0;

  List<String> videosUrls = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/images');
        break;
      case 2:
        break;
      default:
        break;
    }
  }

  void _setVideosUrls() async {
    final response = await http.get(Uri.parse('$serverIp/videos'),
        headers: {"Authorization": widget.jwt});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        videosUrls = data.cast<String>();
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();

    _setVideosUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        actions: [
          IconButton(
              onPressed: () async {
                await camera.availableCameras().then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CameraPage(cameras: value))));
              },
              icon: const Icon(Icons.camera_alt)),
          IconButton(
              onPressed: () async {
                storage.delete(key: "jwt");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(5),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          crossAxisCount: 2,
        ),
        itemCount: videosUrls.length,
        itemBuilder: (context, index) {
          return VideoWidget(
            videoUrl: videosUrls[index],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Videos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
