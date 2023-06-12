import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:solinski_app_flutter/screens/login_page.dart';

const serverIp = 'http://localhost:8000';
const storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  const HomePage(this.jwt, this.payload, {super.key});

  factory HomePage.fromBase64(String jwt) => HomePage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _cardData = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    FlutterNfcKit.finish();
    // NfcManager.instance.stopSession();
  }

  Future<void> _startReading() async {
    try {
      final nfcTag = await FlutterNfcKit.poll();
      // final result = await FlutterNfcKit.readNDEFRecords();
      setState(() {
        _cardData = nfcTag.id;
      });
      // Start Session
      // NfcManager.instance.startSession(
      //   onDiscovered: (NfcTag tag) async {
      //     NfcA? nfca = NfcA.from(tag);

      //     if (nfca == null) {
      //       print('Tag is not compatible with NfcA');
      //       return;
      //     }
      //     print(nfca);
      //   },
      // );
    } catch (e) {
      print('Error reading NFC: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/images');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/videos');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App'),
        actions: [
          IconButton(
              onPressed: () async {
                storage.delete(key: "jwt");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: FutureBuilder(
            future: http.read(Uri.parse('$serverIp/data'),
                headers: {"Authorization": widget.jwt}),
            builder: (context, snapshot) => snapshot.hasData
                ? ElevatedButton(
                    onPressed: _startReading,
                    child: Text(
                      'Hello World, $_cardData ${snapshot.data}',
                    ),
                  )
                : snapshot.hasError
                    ? const Text("An error occurred")
                    : const CircularProgressIndicator()),
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
