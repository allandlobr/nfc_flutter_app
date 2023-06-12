import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart' as camera;
import 'package:solinski_app_flutter/screens/image_preview_page.dart';
import 'package:solinski_app_flutter/screens/login_page.dart';

import 'image_camera_page.dart';

final serverIp = dotenv.get('API_URL');
const storage = FlutterSecureStorage();

class ImagesPage extends StatefulWidget {
  const ImagesPage(this.jwt, this.payload, {super.key});

  factory ImagesPage.fromBase64(String jwt) => ImagesPage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  ImagesPageState createState() => ImagesPageState();
}

class ImagesPageState extends State<ImagesPage> {
  int _selectedIndex = 0;

  List<String> imagesUrls = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/videos');
        break;
      default:
        break;
    }
  }

  void _setImagesUrls() async {
    final response = await http.get(Uri.parse('$serverIp/images'),
        headers: {"Authorization": widget.jwt});
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        imagesUrls = data.cast<String>();
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();

    _setImagesUrls();
  }

  void pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        final XFile = camera.XFile(file.path.toString());
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                      picture: XFile,
                    )));
      }
      print(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
        actions: [
          IconButton(
              onPressed: () async {
                await camera.availableCameras().then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CameraPage(cameras: value))));
              },
              icon: const Icon(Icons.camera_alt)),
          IconButton(onPressed: pickImage, icon: const Icon(Icons.file_open)),
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
        itemCount: imagesUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            imagesUrls[index],
            fit: BoxFit.cover,
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
