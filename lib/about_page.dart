import 'package:flutter/material.dart';
import 'app_locale.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('About Project'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]), borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.route, size: 48, color: Colors.white)),
              const SizedBox(height: 14),
              Text(L.t('Smart Route Finder'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(L.t('ELE253 – DSA Project'), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            ])),
          const SizedBox(height: 16),

          _infoCard(cs, L.t('Project Name'), [
            _row(cs, Icons.app_shortcut, L.t('Smart Route Finder Pro')),
          ]),
          const SizedBox(height: 12),

          _infoCard(cs, L.t('Course'), [
            _row(cs, Icons.school, 'ELE253'),
            _row(cs, Icons.book, L.t('Data Structures and Algorithms')),
          ]),
          const SizedBox(height: 12),

          _infoCard(cs, L.t('Technology'), [
            _row(cs, Icons.flutter_dash, 'Flutter & Dart'),
            _row(cs, Icons.design_services, 'Material Design 3'),
          ]),
          const SizedBox(height: 12),

          _infoCard(cs, L.t('Libraries'), [
            _row(cs, Icons.bar_chart, 'fl_chart — Interactive Charts'),
            _row(cs, Icons.font_download, 'google_fonts — Cairo & Inter'),
          ]),
          const SizedBox(height: 12),

          _infoCard(cs, L.t('Algorithms Used'), [
            _row(cs, Icons.speed, "Dijkstra's Algorithm — O(V²)"),
            _row(cs, Icons.all_inclusive, 'Bellman-Ford Algorithm — O(V·E)'),
          ]),
          const SizedBox(height: 12),

          _infoCard(cs, L.t('Data Structures Used'), [
            _row(cs, Icons.account_tree, L.t('Adjacency List (Map<String, Map<String, int>>)')),
            _row(cs, Icons.sort, L.t('Priority Queue (simulated)')),
            _row(cs, Icons.tag, L.t('Hash Map for distances')),
          ]),
          const SizedBox(height: 12),

          _infoCard(cs, L.t('Version'), [
            _row(cs, Icons.info_outline, '1.0.0+1'),
          ]),
          const SizedBox(height: 24),

          Center(child: Text('Made with ❤️ using Flutter',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
          const SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget _infoCard(ColorScheme cs, String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
      const SizedBox(height: 10),
      ...children,
    ]),
  );

  Widget _row(ColorScheme cs, IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 18, color: cs.primary), const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: cs.onSurface))),
    ]),
  );
}
