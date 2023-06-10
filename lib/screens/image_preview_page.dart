import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  void _deleteImage() {
    final file = File(picture.path);
    file.deleteSync();
  }

  void _uploadImage() async {
    try {
      const url =
          'http://localhost:8000/upload'; // Replace with your Node.js server URL
      final file = File(picture.path);

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
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
                      onPressed: _uploadImage, child: const Text('Save'))
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
