import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../video_widget_file.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.video}) : super(key: key);

  final XFile video;

  void _deleteVideo() {
    final file = File(video.path);
    file.deleteSync();
  }

  void _uploadVideo() async {
    try {
      const url =
          'http://localhost:8000/upload'; // Replace with your Node.js server URL
      final file = File(video.path);

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Video uploaded successfully');
      } else {
        print('Failed to upload video. Status code: ${response.statusCode}');
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
                      onPressed: _uploadVideo, child: const Text('Save'))
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
