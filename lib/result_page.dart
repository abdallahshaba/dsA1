import 'package:flutter/material.dart';
import 'graph.dart';
import 'dijkstra.dart';
import 'route_history.dart';
import 'map_page.dart';
import 'app_locale.dart';

class ResultPage extends StatelessWidget {
  final RouteResult result;
  final Graph graph;
  final String start;
  final String end;
  final List<RouteHistory> history;

  const ResultPage({super.key, required this.result, required this.graph, required this.start, required this.end, required this.history});

  void _goToMap(BuildContext ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => MapPage(graph: graph, result: result, start: start, end: end)));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('Route Result'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (result.pathFound) IconButton(icon: const Icon(Icons.map), tooltip: L.t('View on Map'), onPressed: () => _goToMap(context)),
        ],
      ),
      body: result.pathFound ? _buildSuccess(context, cs) : _buildNoPath(context, cs),
    );
  }

  Widget _buildSuccess(BuildContext context, ColorScheme cs) {
    final directRoad = graph.getWeight(start, end);
    final saved = directRoad > 0 ? directRoad - result.distance : 0;
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _distCard(cs),
        const SizedBox(height: 14),
        _benchmarkCard(cs),
        const SizedBox(height: 14),
        if (directRoad > 0) ...[_compareCard(directRoad, saved, cs), const SizedBox(height: 14)],
        _journeySummary(cs),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(L.t('Route Details'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onSurface)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('${result.hops} ${L.t(result.hops != 1 ? "stops" : "stop")}',
                  style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 14),
        _timeline(cs),
        const SizedBox(height: 20),
        _allDistances(cs),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: () => _goToMap(context),
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.map), label: Text(L.t('View on Map'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.search), label: Text(L.t('Search Again'))),
        const SizedBox(height: 20),
      ],
    ));
  }

  Widget _distCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]), borderRadius: BorderRadius.circular(18)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(L.t('Shortest Distance'), style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 4),
        Text('${result.distance} km', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
      ]),
      Column(children: [
        const Icon(Icons.route, color: Colors.white54, size: 30),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('${result.hops} ${L.t(result.hops != 1 ? "stops" : "stop")}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    ]),
  );

  Widget _benchmarkCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.speed, size: 16, color: cs.primary), const SizedBox(width: 6),
        Text('${L.t('Performance Metrics')} — ${result.algorithmName}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
      ]),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _bmStat(L.t('Time'), '${result.executionMicroseconds} µs', Icons.timer, cs.primary),
        _bmStat(L.t('Visited'), '${result.nodesVisited}', Icons.visibility, Colors.green),
        _bmStat(L.t('Relaxed'), '${result.edgesRelaxed}', Icons.sync_alt, Colors.orange),
      ]),
    ]),
  );

  Widget _bmStat(String label, String val, IconData icon, Color color) => Column(children: [
    Icon(icon, color: color, size: 18), const SizedBox(height: 4),
    Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _compareCard(int directRoad, int saved, ColorScheme cs) {
    final better = result.distance < directRoad;
    final color = better ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(better ? Icons.trending_down : Icons.compare_arrows, color: color), const SizedBox(width: 10),
        Expanded(child: Text(better
            ? '${result.algorithmName} ${L.t('saved')} $saved ${L.t('km vs direct road')} ($directRoad km)'
            : '${L.t('Direct road')}: $directRoad km | ${L.t('This route')}: ${result.distance} km',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.withOpacity(0.9)))),
      ]),
    );
  }

  Widget _journeySummary(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.primary.withOpacity(0.2))),
    child: Row(children: [
      Expanded(child: _cityChip(L.t('From'), start, Icons.my_location, cs.primary)),
      Icon(Icons.arrow_forward_rounded, color: cs.onSurfaceVariant, size: 20),
      Expanded(child: _cityChip(L.t('To'), end, Icons.flag, Colors.green)),
    ]),
  );

  Widget _cityChip(String label, String city, IconData icon, Color color) => Column(children: [
    Icon(icon, color: color, size: 18), const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    Text(city, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color), textAlign: TextAlign.center),
  ]);

  Widget _timeline(ColorScheme cs) => Column(
    children: List.generate(result.path.length, (i) {
      final city = result.path[i];
      final isFirst = i == 0; final isLast = i == result.path.length - 1;
      final color = isFirst ? cs.primary : isLast ? Colors.green : Colors.orange;
      final segDist = !isFirst ? graph.getWeight(result.path[i - 1], city) : -1;
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 44, child: Column(children: [
          CircleAvatar(radius: 15, backgroundColor: color,
              child: Icon(isFirst ? Icons.my_location : isLast ? Icons.flag : Icons.circle, color: Colors.white, size: isFirst || isLast ? 15 : 8)),
          if (!isLast) Container(width: 2, height: 40, color: cs.outlineVariant),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Padding(padding: const EdgeInsets.only(top: 6, bottom: 12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city, style: TextStyle(fontSize: 14, fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
                color: isFirst ? cs.primary : isLast ? Colors.green : cs.onSurface)),
            Text(L.t(isFirst ? 'Starting point' : isLast ? 'Destination' : 'Intermediate stop'),
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          ],
        ))),
        if (!isFirst && segDist > 0) Padding(padding: const EdgeInsets.only(top: 8), child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('$segDist km', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
        )),
      ]);
    }),
  );

  Widget _allDistances(ColorScheme cs) {
    final sorted = result.allDistances.entries.where((e) => e.value < 999999).toList()..sort((a, b) => a.value.compareTo(b.value));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(L.t('All distances from start'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
        const SizedBox(height: 10),
        ...sorted.map((e) {
          final onPath = result.path.contains(e.key);
          return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(onPath ? Icons.circle : Icons.circle_outlined, size: 8, color: onPath ? cs.primary : cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(e.key, style: TextStyle(fontSize: 13, fontWeight: onPath ? FontWeight.w600 : FontWeight.normal, color: onPath ? cs.primary : cs.onSurface)),
              ]),
              Text('${e.value} km', style: TextStyle(fontSize: 13, fontWeight: onPath ? FontWeight.bold : FontWeight.normal, color: onPath ? cs.primary : cs.onSurfaceVariant)),
            ],
          ));
        }),
      ]),
    );
  }

  Widget _buildNoPath(BuildContext context, ColorScheme cs) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.wrong_location, size: 80, color: Colors.redAccent),
      const SizedBox(height: 20),
      Text(L.t('No Route Found'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
      const SizedBox(height: 12),
      Text('${L.t('No road connection exists between')} $start ${L.t('and')} $end.', textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
      if (result.hasNegativeCycle) ...[
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('⚠ ${L.t('Negative cycle detected in graph!')}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
      ],
      const SizedBox(height: 32),
      ElevatedButton.icon(onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.arrow_back), label: Text(L.t('Go Back'))),
    ]),
  ));
}