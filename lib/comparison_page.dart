import 'package:flutter/material.dart';
import 'sorting_data.dart';
import 'bubble_sort.dart';
import 'merge_sort.dart';

class ComparisonPage extends StatefulWidget {
  final List<Student> data;
  const ComparisonPage({super.key, required this.data});
  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  SortResult? _bubble;
  SortResult? _merge;
  bool _running = true;

  @override
  void initState() { super.initState(); _run(); }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final b = BubbleSort.sort(widget.data);
    final m = MergeSort.sort(widget.data);
    if (mounted) setState(() { _bubble = b; _merge = m; _running = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Algorithm Comparison')),
      body: _running ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    const Icon(Icons.compare_arrows, color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    const Text('Bubble Sort vs Merge Sort',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${widget.data.length} students',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                  ])),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _card('Bubble Sort', _bubble!, cs.primary, cs)),
                  const SizedBox(width: 10),
                  Expanded(child: _card('Merge Sort', _merge!, Colors.orange, cs)),
                ]),
                const SizedBox(height: 16),
                _table(cs),
                const SizedBox(height: 16),
                _winner(cs),
                const SizedBox(height: 20),
              ])),
    );
  }

  Widget _card(String name, SortResult r, Color c, ColorScheme cs) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.3), width: 2)),
    child: Column(children: [
      Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: c)),
      const SizedBox(height: 10),
      _m('Time', '${r.executionMicroseconds} µs', cs),
      _m('Comparisons', '${r.comparisons}', cs),
      _m(name == 'Bubble Sort' ? 'Swaps' : 'Merges', '${r.swaps}', cs),
    ]),
  );

  Widget _m(String l, String v, ColorScheme cs) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Column(children: [
      Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      Text(l, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
    ]),
  );

  Widget _table(ColorScheme cs) {
    final b = _bubble!;
    final m = _merge!;
    Widget row(String label, String v1, String v2, {bool header = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(color: header ? cs.primaryContainer.withValues(alpha: 0.5) : null,
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 12, fontWeight: header ? FontWeight.bold : FontWeight.w500))),
        Expanded(child: Text(v1, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: header ? null : cs.primary))),
        Expanded(child: Text(v2, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: header ? null : Colors.orange))),
      ]));
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Detailed Comparison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
        const SizedBox(height: 12),
        row('Metric', 'Bubble', 'Merge', header: true),
        row('Exec Time', '${b.executionMicroseconds} µs', '${m.executionMicroseconds} µs'),
        row('Comparisons', '${b.comparisons}', '${m.comparisons}'),
        row('Operations', '${b.swaps} swaps', '— merges'),
        row('Time Complexity', 'O(n²)', 'O(n log n)'),
        row('Space Complexity', 'O(1)', 'O(n)'),
        row('Approach', 'Iterative', 'Divide & Conquer'),
      ]));
  }

  Widget _winner(ColorScheme cs) {
    final bubbleFaster = _bubble!.executionMicroseconds <= _merge!.executionMicroseconds;
    final w = bubbleFaster ? 'Bubble Sort' : 'Merge Sort';
    final wc = bubbleFaster ? cs.primary : Colors.orange;
    return Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [wc.withValues(alpha: 0.15), wc.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(14), border: Border.all(color: wc.withValues(alpha: 0.4))),
      child: Column(children: [
        Icon(Icons.emoji_events, color: wc, size: 36),
        const SizedBox(height: 8),
        Text('🏆 $w Wins!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: wc)),
        const SizedBox(height: 4),
        Text(bubbleFaster
            ? 'For small lists, Bubble Sort\'s low overhead makes it competitive.'
            : 'Merge Sort\'s O(n log n) efficiency wins for this dataset size.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5)),
      ]));
  }
}
