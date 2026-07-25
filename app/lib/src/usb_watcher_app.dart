import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class UsbWatcherApp extends StatelessWidget {
  const UsbWatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6EA8FE);

    return MaterialApp(
      title: 'USB Watcher',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        cardTheme: const CardThemeData(
          color: Color(0xFF111821),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: const Color(0xFF111821),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
