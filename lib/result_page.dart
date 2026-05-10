import 'package:flutter/material.dart';
import 'sorting_data.dart';

class ResultPage extends StatelessWidget {
  final SortResult result;
  const ResultPage({super.key, required this.result});

  Color _gradeColor(int grade) {
    if (grade >= 85) return Colors.green;
    if (grade >= 70) return Colors.blue;
    if (grade >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('${result.algorithmName} Result')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 48),
              const SizedBox(height: 10),
              const Text('Sorted Successfully!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${result.sorted.length} students sorted by ${result.algorithmName}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
            ])),
          const SizedBox(height: 16),
          Row(children: [
            _metric('Time', '${result.executionMicroseconds} µs', Icons.timer, cs.primary, cs),
            const SizedBox(width: 8),
            _metric('Comparisons', '${result.comparisons}', Icons.compare_arrows, Colors.orange, cs),
            const SizedBox(width: 8),
            _metric(result.algorithmName == 'Bubble Sort' ? 'Swaps' : 'Merges', '${result.swaps}',
                Icons.swap_vert, Colors.green, cs),
          ]),
          const SizedBox(height: 16),
          _studentList('Before Sorting', result.original, cs, Colors.orange),
          const SizedBox(height: 12),
          _studentList('After Sorting (by Grade)', result.sorted, cs, Colors.green),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Algorithm Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
              const SizedBox(height: 8),
              _infoRow('Time Complexity', result.algorithmName == 'Bubble Sort' ? 'O(n²)' : 'O(n log n)', cs),
              _infoRow('Space Complexity', result.algorithmName == 'Bubble Sort' ? 'O(1)' : 'O(n)', cs),
              _infoRow('Approach', result.algorithmName == 'Bubble Sort' ? 'Iterative' : 'Divide & Conquer', cs),
              _infoRow('Stable?', 'Yes', cs),
            ])),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.arrow_back), label: const Text('Back')),
          const SizedBox(height: 20),
        ])),
    );
  }

  Widget _metric(String label, String value, IconData icon, Color color, ColorScheme cs) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant)),
      child: Column(children: [
        Icon(icon, color: color, size: 22), const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
      ])),
  );

  Widget _studentList(String title, List<Student> list, ColorScheme cs, Color accent) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
      const SizedBox(height: 8),
      ...list.take(30).map((s) => Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Container(width: 32, height: 20, alignment: Alignment.center,
            decoration: BoxDecoration(color: _gradeColor(s.grade), borderRadius: BorderRadius.circular(4)),
            child: Text('${s.grade}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Text(s.name, style: TextStyle(fontSize: 12, color: cs.onSurface)),
        ]))),
      if (list.length > 30) Padding(padding: const EdgeInsets.only(top: 6),
          child: Text('... and ${list.length - 30} more', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))),
    ]),
  );

  Widget _infoRow(String label, String value, ColorScheme cs) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary)),
    ]),
  );
}