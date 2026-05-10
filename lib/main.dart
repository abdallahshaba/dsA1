import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

void main() => runApp(const SortApp());

class SortApp extends StatefulWidget {
  const SortApp({super.key});
  @override
  State<SortApp> createState() => _SortAppState();
}

class _SortAppState extends State<SortApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() => setState(() =>
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6C63FF);

    final lightBase = ThemeData(
      brightness: Brightness.light, useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    );
    final darkBase = ThemeData(
      brightness: Brightness.dark, useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    );

    return MaterialApp(
      title: 'Student Grade Sorter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: lightBase.copyWith(
        textTheme: GoogleFonts.interTextTheme(lightBase.textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF2D2B55),
          foregroundColor: Colors.white, centerTitle: true, elevation: 0,
          titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F3FF),
        cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      ),
      darkTheme: darkBase.copyWith(
        textTheme: GoogleFonts.interTextTheme(darkBase.textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A1A2E),
          foregroundColor: Colors.white, centerTitle: true, elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      ),
      home: HomeWrapper(onToggleTheme: toggleTheme),
    );
  }
}

class HomeWrapper extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const HomeWrapper({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const HomePage(),
      Positioned(bottom: 20, right: 20,
        child: FloatingActionButton.small(
          heroTag: 'theme',
          onPressed: onToggleTheme,
          tooltip: 'Toggle Dark Mode',
          child: Icon(Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
    ]);
  }
}