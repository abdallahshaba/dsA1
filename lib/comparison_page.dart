import 'package:flutter/material.dart';
import 'graph.dart';
import 'dijkstra.dart';
import 'bellman_ford.dart';
import 'app_locale.dart';

class ComparisonPage extends StatefulWidget {
  final Graph graph;
  final String start;
  final String end;
  const ComparisonPage({super.key, required this.graph, required this.start, required this.end});
  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  RouteResult? _dij;
  RouteResult? _bf;
  bool _running = true;

  @override
  void initState() { super.initState(); _run(); }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final d = Dijkstra.shortestPath(widget.graph, widget.start, widget.end);
    final b = BellmanFord.shortestPath(widget.graph, widget.start, widget.end);
    if (mounted) setState(() { _dij = d; _bf = b; _running = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.start} → ${widget.end}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: _running ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]), borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    const Icon(Icons.compare_arrows, color: Colors.white, size: 36), const SizedBox(height: 8),
                    Text(L.t('Algorithm Comparison'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(L.t('Dijkstra vs Bellman-Ford'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ])),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _card('Dijkstra', _dij!, cs.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: _card('Bellman-Ford', _bf!, Colors.orange)),
                ]),
                const SizedBox(height: 16), _table(cs),
                const SizedBox(height: 16), _paths(cs),
                const SizedBox(height: 16), _winner(cs),
                const SizedBox(height: 20),
              ])),
    );
  }

  Widget _card(String name, RouteResult r, Color c) {
    final cs = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.3), width: 2)),
      child: Column(children: [
        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: c)), const SizedBox(height: 10),
        _m(L.t('Distance'), r.pathFound ? '${r.distance} km' : L.t('N/A')),
        _m(L.t('Time'), '${r.executionMicroseconds} µs'),
        _m(L.t('Relaxations'), '${r.edgesRelaxed}'),
        _m(L.t('Visited'), '${r.nodesVisited}'),
      ]));
  }

  Widget _m(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(children: [
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(l, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]));

  Widget _table(ColorScheme cs) {
    final d = _dij!; final b = _bf!;
    Widget r(String l, String v1, String v2, {bool h = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(color: h ? cs.primaryContainer.withOpacity(0.5) : null,
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3)))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(l, style: TextStyle(fontSize: 12, fontWeight: h ? FontWeight.bold : FontWeight.w500))),
        Expanded(child: Text(v1, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: h ? cs.primary : cs.onSurface))),
        Expanded(child: Text(v2, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: h ? Colors.orange : cs.onSurface))),
      ]));
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(L.t('Detailed Comparison'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
        const SizedBox(height: 12),
        r(L.t('Metric'), 'Dijkstra', 'Bellman-Ford', h: true),
        r(L.t('Distance'), '${d.distance} km', '${b.distance} km'),
        r(L.t('Exec Time'), '${d.executionMicroseconds} µs', '${b.executionMicroseconds} µs'),
        r(L.t('Relaxations'), '${d.edgesRelaxed}', '${b.edgesRelaxed}'),
        r(L.t('Visited'), '${d.nodesVisited}', '${b.nodesVisited}'),
        r(L.t('Neg. Cycles'), L.t('N/A'), b.hasNegativeCycle ? L.t('Detected!') : L.t('None')),
        r(L.t('Complexity'), 'O(V²)', 'O(V·E)'),
      ]));
  }

  Widget _paths(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(L.t('Path Comparison'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
      const SizedBox(height: 10),
      _pRow('Dijkstra', _dij!, cs.primary), const SizedBox(height: 8),
      _pRow('Bellman-Ford', _bf!, Colors.orange), const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cs.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
          child: Text(_dij!.path.join('→') == _bf!.path.join('→')
              ? '✓ ${L.t('Both algorithms found the same optimal path!')}'
              : '⚠ ${L.t('Different paths found (both may be optimal if same distance).')}',
              style: TextStyle(fontSize: 12, color: cs.onSurface))),
    ]));

  Widget _pRow(String n, RouteResult r, Color c) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Text(n, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c))),
    const SizedBox(width: 8),
    Expanded(child: Text(r.pathFound ? r.path.join(' → ') : L.t('No path'), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
  ]);

  Widget _winner(ColorScheme cs) {
    final dijkFaster = _dij!.executionMicroseconds <= _bf!.executionMicroseconds;
    final w = dijkFaster ? 'Dijkstra' : 'Bellman-Ford';
    final wc = dijkFaster ? cs.primary : Colors.orange;
    return Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [wc.withOpacity(0.15), wc.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(14), border: Border.all(color: wc.withOpacity(0.4))),
      child: Column(children: [
        Icon(Icons.emoji_events, color: wc, size: 36), const SizedBox(height: 8),
        Text('🏆 $w ${L.t('Wins!')}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: wc)),
        const SizedBox(height: 4),
        Text(L.t(dijkFaster
            ? 'Dijkstra\'s greedy approach is more efficient for non-negative weights.'
            : 'Bellman-Ford performed better due to early termination.'),
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5)),
      ]));
  }
}
