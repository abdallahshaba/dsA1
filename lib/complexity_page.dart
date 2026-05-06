import 'package:flutter/material.dart';
import 'app_locale.dart';

class ComplexityPage extends StatelessWidget {
  const ComplexityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('Complexity Analysis'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionCard(context, L.t('Dijkstra\'s Algorithm'), Icons.speed, cs.primary, [
            _subTitle(L.t('Description')),
            Text(L.t('A greedy algorithm that finds the shortest path from a single source to all other vertices in a weighted graph with non-negative edge weights. It works by always selecting the unvisited vertex with the smallest known distance and relaxing its neighbors.'),
                style: const TextStyle(height: 1.6, fontSize: 13)),
            const SizedBox(height: 16), _subTitle(L.t('Pseudocode')),
            _codeBlock(isDark,
              'DIJKSTRA(G, source, target):\n  for each vertex v in G:\n    dist[v] ← ∞\n    prev[v] ← NULL\n  dist[source] ← 0\n  Q ← all vertices\n\n  while Q is not empty:\n    u ← vertex in Q with min dist[u]\n    remove u from Q\n    for each neighbor v of u:\n      alt ← dist[u] + weight(u, v)\n      if alt < dist[v]:\n        dist[v] ← alt\n        prev[v] ← u\n\n  return dist[], prev[]'),
            const SizedBox(height: 16), _subTitle(L.t('Complexity')),
            _complexityTable(context, 'O(V²)', 'O(V²)', 'O(V²)', 'O(V + E)'),
          ]),
          const SizedBox(height: 16),
          _sectionCard(context, L.t('Bellman-Ford Algorithm'), Icons.all_inclusive, Colors.orange, [
            _subTitle(L.t('Description')),
            Text(L.t('A dynamic programming algorithm that computes shortest paths from a single source vertex to all other vertices. Unlike Dijkstra, it can handle negative edge weights and detect negative cycles. It relaxes all edges V-1 times.'),
                style: const TextStyle(height: 1.6, fontSize: 13)),
            const SizedBox(height: 16), _subTitle(L.t('Pseudocode')),
            _codeBlock(isDark,
              'BELLMAN-FORD(G, source, target):\n  for each vertex v in G:\n    dist[v] ← ∞\n    prev[v] ← NULL\n  dist[source] ← 0\n\n  for i from 1 to |V| - 1:\n    for each edge (u, v, w) in G:\n      if dist[u] + w < dist[v]:\n        dist[v] ← dist[u] + w\n        prev[v] ← u\n\n  // Negative cycle detection\n  for each edge (u, v, w) in G:\n    if dist[u] + w < dist[v]:\n      return "Negative cycle!"\n\n  return dist[], prev[]'),
            const SizedBox(height: 16), _subTitle(L.t('Complexity')),
            _complexityTable(context, 'O(V·E)', 'O(V·E)', 'O(V+E)*', 'O(V)'),
          ]),
          const SizedBox(height: 16),
          _sectionCard(context, L.t('Head-to-Head Comparison'), Icons.compare_arrows, Colors.purple, [
            _comparisonTable(context),
            const SizedBox(height: 16), _subTitle(L.t('When to Use Which?')),
            _bulletPoint(L.t('Use Dijkstra when all edge weights are non-negative — it\'s faster.')),
            _bulletPoint(L.t('Use Bellman-Ford when the graph may have negative weights.')),
            _bulletPoint(L.t('Bellman-Ford can detect negative cycles; Dijkstra cannot.')),
            _bulletPoint(L.t('For sparse graphs, Dijkstra with a min-heap is O((V+E) log V).')),
          ]),
          const SizedBox(height: 16),
          _sectionCard(context, L.t('Data Structure: Adjacency List'), Icons.account_tree, Colors.teal, [
            Text(L.isArabic
                ? 'نمثل الرسم البياني كقائمة تجاور (Map<String, Map<String, int>>). كل مفتاح هو مدينة، وقيمته تربط المدن المجاورة بأوزان الحواف.'
                : 'We represent the graph as an adjacency list (Map<String, Map<String, int>>). Each key is a city, and its value maps neighboring cities to edge weights.',
                style: const TextStyle(height: 1.6, fontSize: 13)),
            const SizedBox(height: 12), _subTitle(L.t('Why Adjacency List over Matrix?')),
            _bulletPoint(L.t('Our graph is sparse (E=16 << V²=196) — list saves memory.')),
            _bulletPoint(L.t('Adjacency List: O(V+E) space vs Matrix: O(V²) space.')),
            _bulletPoint(L.t('Iterating neighbors is O(degree) vs O(V) for matrix.')),
            _bulletPoint(L.t('Adding/removing edges is O(1) for both.')),
          ]),
          const SizedBox(height: 24),
        ])),
    );
  }

  Widget _sectionCard(BuildContext context, String title, IconData icon, Color accent, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outlineVariant),
          boxShadow: [BoxShadow(color: accent.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: accent, size: 22), const SizedBox(width: 10),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: cs.onSurface)))]),
        const SizedBox(height: 14), ...children,
      ]));
  }

  Widget _subTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)));

  Widget _codeBlock(bool isDark, String code) => Container(width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
    child: Text(code, style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.5, color: isDark ? const Color(0xFFCDD6F4) : Colors.black87)));

  Widget _bulletPoint(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5))),
    ]));

  Widget _complexityTable(BuildContext ctx, String best, String avg, String worst, String space) {
    final cs = Theme.of(ctx).colorScheme;
    return Table(border: TableBorder.all(color: cs.outlineVariant, borderRadius: BorderRadius.circular(8)), children: [
      _tableRow(ctx, [L.t('Case'), L.t('Time'), L.t('Space')], header: true),
      _tableRow(ctx, [L.t('Best'), best, space]),
      _tableRow(ctx, [L.t('Average'), avg, space]),
      _tableRow(ctx, [L.t('Worst'), worst, space]),
    ]);
  }

  Widget _comparisonTable(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return Table(border: TableBorder.all(color: cs.outlineVariant, borderRadius: BorderRadius.circular(8)), children: [
      _tableRow(ctx, [L.t('Feature'), 'Dijkstra', 'Bellman-Ford'], header: true),
      _tableRow(ctx, [L.t('Time'), 'O(V²)', 'O(V·E)']),
      _tableRow(ctx, [L.t('Space'), 'O(V+E)', 'O(V)']),
      _tableRow(ctx, [L.t('Neg. Weights'), '✗', '✓']),
      _tableRow(ctx, [L.t('Neg. Cycles'), '✗', '✓ ${L.t('Detect')}']),
      _tableRow(ctx, [L.t('Approach'), L.t('Greedy'), L.t('Dynamic Prog.')]),
      _tableRow(ctx, [L.t('Faster?'), '✓ ${L.t('Usually')}', '✗ ${L.t('Slower')}']),
    ]);
  }

  TableRow _tableRow(BuildContext ctx, List<String> cells, {bool header = false}) {
    final cs = Theme.of(ctx).colorScheme;
    return TableRow(decoration: header ? BoxDecoration(color: cs.primaryContainer) : null,
      children: cells.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(c, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: header ? FontWeight.bold : FontWeight.normal,
                color: header ? cs.onPrimaryContainer : cs.onSurface)))).toList());
  }
}
