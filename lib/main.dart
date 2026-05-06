import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'splash_screen.dart';
import 'app_locale.dart';

void main() {
  runApp(const SmartRouteApp());
}

class SmartRouteApp extends StatefulWidget {
  const SmartRouteApp({super.key});
  static final GlobalKey<_SmartRouteAppState> appKey = GlobalKey<_SmartRouteAppState>();
  @override
  State<SmartRouteApp> createState() => _SmartRouteAppState();
}

class _SmartRouteAppState extends State<SmartRouteApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _showSplash = true;

  void toggleTheme() => setState(() => _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  void toggleLocale() => setState(() => L.isArabic = !L.isArabic);

  void _onSplashDone() { if (mounted) setState(() => _showSplash = false); }

  TextTheme _buildTextTheme(TextTheme base) {
    if (L.isArabic) {
      return GoogleFonts.cairoTextTheme(base);
    } else {
      return GoogleFonts.interTextTheme(base);
    }
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF1A73E8);

    final lightBase = ThemeData(brightness: Brightness.light, useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light));
    final darkBase = ThemeData(brightness: Brightness.dark, useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark));

    return MaterialApp(
      title: 'Smart Route Finder Pro',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: L.isArabic ? const Locale('ar') : const Locale('en'),
      theme: lightBase.copyWith(
        textTheme: _buildTextTheme(lightBase.textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1B2A4A),
          foregroundColor: Colors.white,
          centerTitle: true, elevation: 0,
          titleTextStyle: (L.isArabic ? GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)
              : GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
        cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      ),
      darkTheme: darkBase.copyWith(
        textTheme: _buildTextTheme(darkBase.textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D1117),
          foregroundColor: Colors.white,
          centerTitle: true, elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: (L.isArabic ? GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)
              : GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      ),
      builder: (context, child) => Directionality(
        textDirection: L.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: _showSplash ? SplashScreen(onFinished: _onSplashDone) : const HomeWrapper(),
    );
  }
}

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const HomePage(),
      Positioned(bottom: 20, right: L.isArabic ? null : 20, left: L.isArabic ? 20 : null,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Language toggle
          FloatingActionButton.small(
            heroTag: 'lang',
            onPressed: () {
              final state = context.findAncestorStateOfType<_SmartRouteAppState>();
              state?.toggleLocale();
            },
            tooltip: L.t('Language'),
            child: Text(L.isArabic ? 'EN' : 'ع', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 8),
          // Theme toggle
          FloatingActionButton.small(
            heroTag: 'theme',
            onPressed: () {
              final state = context.findAncestorStateOfType<_SmartRouteAppState>();
              state?.toggleTheme();
            },
            tooltip: L.t('Toggle Dark Mode'),
            child: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ]),
      ),
    ]);
  }
}