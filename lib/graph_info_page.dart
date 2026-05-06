import 'package:flutter/material.dart';
import 'graph.dart';
import 'app_locale.dart';

class GraphInfoPage extends StatelessWidget {
  final Graph graph;
  const GraphInfoPage({super.key, required this.graph});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nodes = graph.getNodes()..sort();
    final heaviest = graph.getHeaviestEdges(5);

    return Scaffold(
      appBar: AppBar(title: Text(L.t('Graph Info'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Stats
          Row(children: [
            _stat(L.t('Cities'), '${graph.nodeCount}', Icons.location_city, cs.primary, cs),
            const SizedBox(width: 8),
            _stat(L.t('Roads'), '${graph.edgeCount}', Icons.alt_route, Colors.green, cs),
            const SizedBox(width: 8),
            _stat(L.t('Density'), graph.density.toStringAsFixed(2), Icons.grain, Colors.purple, cs),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _stat(L.t('Connected'), graph.isConnected ? L.t('Yes') : L.t('No'), Icons.link, graph.isConnected ? Colors.green : Colors.red, cs),
            const SizedBox(width: 8),
            _stat(L.t('Total'), '${graph.getAllEdges().fold<int>(0, (s, e) => s + (e['weight'] as int))} km', Icons.straighten, Colors.orange, cs),
          ]),
          const SizedBox(height: 16),

          // Heaviest roads
          Text(L.t('Heaviest Roads'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 8),
          ...heaviest.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: cs.outlineVariant)),
            child: Row(children: [
              Expanded(child: Text('${e['from']} ↔ ${e['to']}', style: const TextStyle(fontSize: 13))),
              Text('${e['weight']} km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
            ]),
          )),
          const SizedBox(height: 16),

          // Node degrees
          Text(L.t('Node Degrees'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: nodes.map((n) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
            child: Text('$n: ${graph.degree(n)} ${L.t('connections')}', style: TextStyle(fontSize: 12, color: cs.onSurface)),
          )).toList()),
          const SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color, ColorScheme cs) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 20), const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
      ])));
}