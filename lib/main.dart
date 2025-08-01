
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Cine1895App());
}

class Cine1895App extends StatelessWidget {
  const Cine1895App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cine1895 Camera',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
