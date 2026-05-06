import 'package:flutter/material.dart';
import 'app_locale.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  double _textOp = 0;
  double _subOp = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _animate();
  }

  Future<void> _animate() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _textOp = 1);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _subOp = 1);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF161B22), const Color(0xFF0D1117)]
                : [const Color(0xFF1A73E8), const Color(0xFF4285F4), const Color(0xFF1B2A4A)]),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedBuilder(animation: _ctrl, builder: (_, __) => Opacity(opacity: _opacity.value,
            child: Transform.scale(scale: _scale.value,
              child: Container(padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)]),
                child: const Icon(Icons.route, size: 64, color: Colors.white))))),
          const SizedBox(height: 30),
          AnimatedOpacity(opacity: _textOp, duration: const Duration(milliseconds: 500),
            child: Text(L.t('Smart Route Finder'),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
          const SizedBox(height: 12),
          AnimatedOpacity(opacity: _subOp, duration: const Duration(milliseconds: 500),
            child: Column(children: [
              Text(L.t('ELE253 – DSA Project'), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              const SizedBox(height: 8),
              Text(L.t('Powered by Flutter & Dart'), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ])),
          const SizedBox(height: 60),
          AnimatedOpacity(opacity: _subOp, duration: const Duration(milliseconds: 500),
            child: SizedBox(width: 28, height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white.withOpacity(0.6)))),
        ]),
      ),
    );
  }
}
