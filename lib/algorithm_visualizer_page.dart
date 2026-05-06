import 'package:flutter/material.dart';
import 'graph.dart';
import 'app_locale.dart';

class AlgoStep {
  final String type; // 'init', 'visit', 'relax', 'done'
  final String description;
  final String? currentNode;
  final String? targetNode;
  final int? newDist;
  final Map<String, int> distances;
  final Set<String> visited;
  const AlgoStep({required this.type, required this.description, this.currentNode, this.targetNode, this.newDist, required this.distances, required this.visited});
}

class AlgorithmVisualizerPage extends StatefulWidget {
  final Graph graph;
  const AlgorithmVisualizerPage({super.key, required this.graph});
  @override
  State<AlgorithmVisualizerPage> createState() => _AlgorithmVisualizerPageState();
}

class _AlgorithmVisualizerPageState extends State<AlgorithmVisualizerPage> {
  String? _start;
  String? _end;
  String _algo = 'Dijkstra';
  List<AlgoStep>? _steps;
  int _currentStep = 0;
  bool _playing = false;
  double _speed = 1.0;

  List<AlgoStep> _runDijkstraSteps(String start, String end) {
    final steps = <AlgoStep>[];
    final dist = <String, int>{};
    final prev = <String, String?>{};
    final done = <String>{};
    for (final n in widget.graph.adjList.keys) { dist[n] = 999999; prev[n] = null; }
    dist[start] = 0;
    steps.add(AlgoStep(type: 'init', description: L.t('Set all distances to ∞, source to 0'), distances: Map.from(dist), visited: Set.from(done)));

    while (done.length != widget.graph.adjList.length) {
      String? current; int minD = 999999;
      for (final n in dist.keys) { if (!done.contains(n) && dist[n]! < minD) { minD = dist[n]!; current = n; } }
      if (current == null) break;
      done.add(current);
      steps.add(AlgoStep(type: 'visit', description: '${L.t('Visit Node')}: $current (dist=${dist[current]})', currentNode: current, distances: Map.from(dist), visited: Set.from(done)));

      for (final nb in widget.graph.adjList[current]!.keys) {
        final nd = dist[current]! + widget.graph.adjList[current]![nb]!;
        if (nd < dist[nb]!) {
          dist[nb] = nd; prev[nb] = current;
          steps.add(AlgoStep(type: 'relax', description: '${L.t('Relax Edge')}: $current → $nb (${dist[current]!} + ${widget.graph.adjList[current]![nb]!} = $nd < ${dist[nb]! == 999999 ? "∞" : dist[nb]})',
              currentNode: current, targetNode: nb, newDist: nd, distances: Map.from(dist), visited: Set.from(done)));
        }
      }
    }
    final path = <String>[]; String? t = end;
    while (t != null) { path.insert(0, t); t = prev[t]; }
    final found = path.isNotEmpty && path.first == start && dist[end]! < 999999;
    steps.add(AlgoStep(type: 'done', description: found ? '${L.t('Path Found')}: ${path.join(" → ")} = ${dist[end]} km' : L.t('No Path'), distances: Map.from(dist), visited: Set.from(done)));
    return steps;
  }

  List<AlgoStep> _runBellmanFordSteps(String start, String end) {
    final steps = <AlgoStep>[];
    final nodes = widget.graph.getNodes();
    final dist = <String, int>{};
    final prev = <String, String?>{};
    for (final n in nodes) { dist[n] = 999999; prev[n] = null; }
    dist[start] = 0;
    steps.add(AlgoStep(type: 'init', description: L.t('Set all distances to ∞, source to 0'), distances: Map.from(dist), visited: <String>{}));

    final edges = <List<dynamic>>[];
    for (final u in widget.graph.adjList.keys) {
      for (final e in widget.graph.adjList[u]!.entries) { edges.add([u, e.key, e.value]); }
    }

    for (int i = 0; i < nodes.length - 1; i++) {
      bool updated = false;
      for (final edge in edges) {
        final u = edge[0] as String; final v = edge[1] as String; final w = edge[2] as int;
        if (dist[u]! < 999999 && dist[u]! + w < dist[v]!) {
          dist[v] = dist[u]! + w; prev[v] = u; updated = true;
          steps.add(AlgoStep(type: 'relax', description: '${L.t('Relax Edge')} (i=$i): $u → $v (${dist[u]!} + $w = ${dist[u]! + w})',
              currentNode: u, targetNode: v, newDist: dist[v], distances: Map.from(dist), visited: <String>{}));
        }
      }
      if (!updated) break;
    }
    final path = <String>[]; String? t = end; final vis = <String>{};
    while (t != null && !vis.contains(t)) { vis.add(t); path.insert(0, t); t = prev[t]; }
    final found = path.isNotEmpty && path.first == start && dist[end]! < 999999;
    steps.add(AlgoStep(type: 'done', description: found ? '${L.t('Path Found')}: ${path.join(" → ")} = ${dist[end]} km' : L.t('No Path'), distances: Map.from(dist), visited: <String>{}));
    return steps;
  }

  void _visualize() {
    if (_start == null || _end == null) { _snack(L.t('Please select start and end cities')); return; }
    final steps = _algo == 'Dijkstra' ? _runDijkstraSteps(_start!, _end!) : _runBellmanFordSteps(_start!, _end!);
    setState(() { _steps = steps; _currentStep = 0; _playing = false; });
  }

  Future<void> _play() async {
    setState(() => _playing = true);
    while (_playing && _currentStep < _steps!.length - 1) {
      await Future.delayed(Duration(milliseconds: (1000 / _speed).round()));
      if (!mounted || !_playing) break;
      setState(() => _currentStep++);
    }
    if (mounted) setState(() => _playing = false);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nodes = widget.graph.getNodes()..sort();
    return Scaffold(
      appBar: AppBar(title: Text(L.t('Algorithm Visualizer'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controls
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(value: _start, isExpanded: true,
                    decoration: InputDecoration(labelText: L.t('Select Start City'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: nodes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _start = v))),
                const SizedBox(width: 8),
                Expanded(child: DropdownButtonFormField<String>(value: _end, isExpanded: true,
                    decoration: InputDecoration(labelText: L.t('Select End City'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: nodes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _end = v))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                for (final a in ['Dijkstra', 'Bellman-Ford'])
                  Expanded(child: GestureDetector(onTap: () => setState(() => _algo = a),
                    child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: _algo == a ? cs.primary : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                      child: Text(a, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _algo == a ? cs.onPrimary : cs.onSurfaceVariant))))),
              ]),
              const SizedBox(height: 10),
              ElevatedButton.icon(onPressed: _visualize, style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary, minimumSize: const Size.fromHeight(44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.play_circle_outline), label: Text(L.t('Visualize'), style: const TextStyle(fontWeight: FontWeight.bold))),
            ])),
          const SizedBox(height: 16),

          if (_steps != null) ...[
            // Playback controls
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
              child: Column(children: [
                Text('${L.t('Step')} ${_currentStep + 1} ${L.t('of')} ${_steps!.length}', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
                Slider(value: _currentStep.toDouble(), min: 0, max: (_steps!.length - 1).toDouble(), divisions: _steps!.length - 1,
                    onChanged: (v) => setState(() { _currentStep = v.toInt(); _playing = false; })),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(onPressed: _currentStep > 0 ? () => setState(() { _currentStep--; _playing = false; }) : null, icon: const Icon(Icons.skip_previous)),
                  IconButton(onPressed: _playing ? () => setState(() => _playing = false) : (_currentStep < _steps!.length - 1 ? _play : null),
                      icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle, size: 36, color: cs.primary)),
                  IconButton(onPressed: _currentStep < _steps!.length - 1 ? () => setState(() { _currentStep++; _playing = false; }) : null, icon: const Icon(Icons.skip_next)),
                ]),
                Row(children: [
                  Text('${L.t('Speed')}:', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  Expanded(child: Slider(value: _speed, min: 0.5, max: 4.0, divisions: 7, label: '${_speed}x',
                      onChanged: (v) => setState(() => _speed = v))),
                ]),
              ])),
            const SizedBox(height: 12),

            // Current step card
            _stepCard(_steps![_currentStep], cs),
            const SizedBox(height: 12),

            // Distances table
            _distancesTable(_steps![_currentStep], cs),
            const SizedBox(height: 12),

            // Steps history
            Text(L.t('Step') + 's', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
            const SizedBox(height: 8),
            ...List.generate(_steps!.length, (i) => _miniStep(i, _steps![i], cs)),
            const SizedBox(height: 20),
          ],
        ],
      )),
    );
  }

  Widget _stepCard(AlgoStep step, ColorScheme cs) {
    Color accent;
    IconData icon;
    switch (step.type) {
      case 'init': accent = Colors.blue; icon = Icons.flag; break;
      case 'visit': accent = Colors.green; icon = Icons.visibility; break;
      case 'relax': accent = Colors.orange; icon = Icons.sync_alt; break;
      case 'done': accent = Colors.purple; icon = Icons.check_circle; break;
      default: accent = cs.primary; icon = Icons.circle;
    }
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: accent.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: accent, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(step.type.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: accent)),
          const SizedBox(height: 4),
          Text(step.description, style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _distancesTable(AlgoStep step, ColorScheme cs) {
    final entries = step.distances.entries.where((e) => e.value < 999999).toList()..sort((a, b) => a.value.compareTo(b.value));
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(L.t('Current Distances'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: entries.map((e) {
          final isVisited = step.visited.contains(e.key);
          final isCurrent = e.key == step.currentNode;
          final isTarget = e.key == step.targetNode;
          return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.green.withOpacity(0.15) : isTarget ? Colors.orange.withOpacity(0.15) : isVisited ? cs.primaryContainer.withOpacity(0.3) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isCurrent ? Colors.green : isTarget ? Colors.orange : Colors.transparent, width: isCurrent || isTarget ? 2 : 0)),
            child: Text('${e.key}: ${e.value}', style: TextStyle(fontSize: 11, fontWeight: isCurrent || isTarget ? FontWeight.bold : FontWeight.normal, color: cs.onSurface)));
        }).toList()),
        if (step.distances.values.any((v) => v >= 999999)) ...[
          const SizedBox(height: 6),
          Text('∞: ${step.distances.entries.where((e) => e.value >= 999999).map((e) => e.key).join(", ")}',
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
        ],
      ]),
    );
  }

  Widget _miniStep(int i, AlgoStep step, ColorScheme cs) {
    final isCurrent = i == _currentStep;
    Color accent;
    switch (step.type) { case 'init': accent = Colors.blue; break; case 'visit': accent = Colors.green; break; case 'relax': accent = Colors.orange; break; default: accent = Colors.purple; }
    return GestureDetector(onTap: () => setState(() { _currentStep = i; _playing = false; }),
      child: Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isCurrent ? accent.withOpacity(0.1) : null, borderRadius: BorderRadius.circular(8),
            border: isCurrent ? Border.all(color: accent, width: 1.5) : null),
        child: Row(children: [
          SizedBox(width: 28, child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accent))),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(step.description, style: TextStyle(fontSize: 11, color: isCurrent ? cs.onSurface : cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ])),
    );
  }
}
