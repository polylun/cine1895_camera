
import 'package:flutter/material.dart';

void main() => runApp(Cine1895CameraApp());

class Cine1895CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cine1895 Camera',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(child: Text('Cine1895 Camera - Ready for GitHub')),
      ),
    );
  }
}
