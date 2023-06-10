import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: _startReading,
        child: Text('Hello World, $_cardData'),
      )),
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
