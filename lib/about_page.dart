import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About Project')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.school, size: 48, color: Colors.white)),
              const SizedBox(height: 14),
              const Text('Student Grade Sorter',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('ELE253 – DSA Project',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
            ])),
          const SizedBox(height: 16),
          _infoCard(cs, 'Problem Statement', [
            const Padding(padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Universities need to sort and rank thousands of students by their grades efficiently. '
                  'This app compares two sorting algorithms to find which is faster for different dataset sizes.',
                  style: TextStyle(fontSize: 13, height: 1.6))),
          ]),
          const SizedBox(height: 12),
          _infoCard(cs, 'Course', [
            _row(cs, Icons.school, 'ELE253'),
            _row(cs, Icons.book, 'Data Structures and Algorithms'),
          ]),
          const SizedBox(height: 12),
          _infoCard(cs, 'Technology', [
            _row(cs, Icons.flutter_dash, 'Flutter & Dart'),
            _row(cs, Icons.design_services, 'Material Design 3'),
          ]),
          const SizedBox(height: 12),
          _infoCard(cs, 'Libraries', [
            _row(cs, Icons.bar_chart, 'fl_chart — Interactive Charts'),
            _row(cs, Icons.font_download, 'google_fonts — Inter font'),
          ]),
          const SizedBox(height: 12),
          _infoCard(cs, 'Algorithms', [
            _row(cs, Icons.bubble_chart, 'Bubble Sort — O(n²) — Iterative'),
            _row(cs, Icons.call_split, 'Merge Sort — O(n log n) — Divide & Conquer'),
          ]),
          const SizedBox(height: 12),
          _infoCard(cs, 'Data Structure', [
            _row(cs, Icons.view_list, 'Dynamic Array (List<Student>)'),
            _row(cs, Icons.info_outline, 'Chosen over Linked List for O(1) random access'),
          ]),
          const SizedBox(height: 24),
          Center(child: Text('Made with ❤️ using Flutter',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
          const SizedBox(height: 20),
        ])),
    );
  }

  Widget _infoCard(ColorScheme cs, String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
      const SizedBox(height: 10), ...children,
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
