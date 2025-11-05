import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/glider_profiles/presentation/pages/glider_profiles_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glider Flight Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D47A1), // Глубокий синий
        scaffoldBackgroundColor: const Color(0xFF121212), // Стандартный темный фон
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E), // Чуть светлее фона
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF64B5F6), // Светло-синий акцент
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const GliderProfilesPage(),
    );
  }
}