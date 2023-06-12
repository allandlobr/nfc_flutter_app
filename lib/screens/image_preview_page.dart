import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:solinski_app_flutter/screens/login_page.dart';

const storage = FlutterSecureStorage();

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  void _deleteImage() {
    final file = File(picture.path);
    file.deleteSync();
  }

  void _uploadImage(BuildContext context) async {
    try {
      final jwt = await jwtOrEmpty;

      if (jwt.isEmpty) {
        storage.delete(key: 'jwt');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }

      const url =
          'http://localhost:8000/upload'; // Replace with your Node.js server URL
      final file = File(picture.path);

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.putIfAbsent('Authorization', () => jwt);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 50,
                children: [
                  ElevatedButton(
                      onPressed: _deleteImage, child: const Text('Delete')),
                  ElevatedButton(
                      onPressed: () => _uploadImage(context),
                      child: const Text('Save'))
                ],
              )
            ],
          ),
          Text(picture.path)
        ]),
      ),
    );
  }
}
