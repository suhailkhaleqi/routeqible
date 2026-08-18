import 'package:flutter/material.dart';
import 'package:routeqible/screens/qibla_screen.dart';

void main() {
  runApp(const RouteQibleApp());
}

class RouteQibleApp extends StatelessWidget {
  const RouteQibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RouteQibla',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const QiblaScreen(),
    );
  }
}
