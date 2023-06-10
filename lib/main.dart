import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/images_page.dart';
import 'screens/videos_page.dart';

void main() {
  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/images': (context) => const ImagesPage(),
        '/videos': (context) => const VideosPage(),
      },
    );
  }
}
