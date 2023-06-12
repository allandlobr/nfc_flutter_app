import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:solinski_app_flutter/screens/login_page.dart';
import '../video_widget_file.dart';

const storage = FlutterSecureStorage();

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.video}) : super(key: key);

  final XFile video;

  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  void _deleteVideo() {
    final file = File(video.path);
    file.deleteSync();
  }

  void _uploadVideo(BuildContext context) async {
    try {
      final jwt = await jwtOrEmpty;

      if (jwt.isEmpty) {
        storage.delete(key: 'jwt');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }

      const url =
          'http://localhost:8000/upload'; // Replace with your Node.js server URL
      final file = File(video.path);

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.putIfAbsent('Authorization', () => jwt);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Video uploaded successfully');
      } else {
        print('Failed to upload video. Status code: ${response.statusCode}');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } catch (e) {
      print('Error uploading video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
              height: 400, child: VideoWidget(videoFile: File(video.path))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 50,
                children: [
                  ElevatedButton(
                      onPressed: _deleteVideo, child: const Text('Delete')),
                  ElevatedButton(
                      onPressed: () => _uploadVideo(context),
                      child: const Text('Save'))
                ],
              )
            ],
          ),
          Text(video.path)
        ]),
      ),
    );
  }
}
