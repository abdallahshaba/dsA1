import 'package:flutter/material.dart';
import 'graph.dart';
import 'dijkstra.dart';
import 'bellman_ford.dart';
import 'result_page.dart';
import 'comparison_page.dart';
import 'benchmark_page.dart';
import 'complexity_page.dart';
import 'graph_editor_page.dart';
import 'about_page.dart';
import 'app_locale.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Graph _graph = Graph();
  String? _start;
  String? _end;
  bool _loading = false;
  String _algo = 'Dijkstra';

  @override
  void initState() { super.initState(); _buildGraph(); }

  void _buildGraph() {
    _graph.addEdge('Cairo', 'Giza', 20);
    _graph.addEdge('Cairo', 'Alexandria', 220);
    _graph.addEdge('Cairo', 'Suez', 134);
    _graph.addEdge('Cairo', 'Ismailia', 120);
    _graph.addEdge('Cairo', 'Aswan', 900);
    _graph.addEdge('Giza', 'Fayoum', 100);
    _graph.addEdge('Alexandria', 'Tanta', 94);
    _graph.addEdge('Alexandria', 'Marsa Matruh', 290);
    _graph.addEdge('Tanta', 'Cairo', 95);
    _graph.addEdge('Fayoum', 'Minya', 170);
    _graph.addEdge('Minya', 'Assiut', 120);
    _graph.addEdge('Assiut', 'Sohag', 115);
    _graph.addEdge('Sohag', 'Luxor', 160);
    _graph.addEdge('Luxor', 'Aswan', 215);
    _graph.addEdge('Suez', 'Ismailia', 78);
    _graph.addEdge('Ismailia', 'Port Said', 85);
  }

  Future<void> _findPath() async {
    if (_start == null || _end == null) { _snack(L.t('Please select both cities.')); return; }
    if (_start == _end) { _snack(L.t('Start and destination must be different.')); return; }

    if (_algo == 'Compare') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ComparisonPage(graph: _graph, start: _start!, end: _end!)));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 200));

    final result = _algo == 'Bellman-Ford'
        ? BellmanFord.shortestPath(_graph, _start!, _end!)
        : Dijkstra.shortestPath(_graph, _start!, _end!);

    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, a, __) => ResultPage(result: result, graph: _graph, start: _start!, end: _end!),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  void _swap() => setState(() { final t = _start; _start = _end; _end = t; });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nodes = _graph.getNodes()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('Smart Route Finder'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
        centerTitle: true,
      ),
      drawer: _buildDrawer(cs),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Icon(Icons.map_outlined, size: 64, color: cs.primary),
          const SizedBox(height: 8),
          Text(L.t('Find the shortest route between Egyptian cities'), textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          _statsRow(cs),
          const SizedBox(height: 20),
          Text(L.t('Algorithm'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 6),
          _algoSelector(cs),
          const SizedBox(height: 16),
          Text(L.t('Starting City'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 6),
          _dropdown(hint: L.t('Select starting city'), icon: Icons.my_location, iconColor: cs.primary, value: _start, nodes: nodes, onChanged: (v) => setState(() => _start = v), cs: cs),
          const SizedBox(height: 10),
          Center(child: GestureDetector(onTap: _swap, child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: cs.primary, width: 1.5)),
            child: Icon(Icons.swap_vert, color: cs.primary, size: 22),
          ))),
          const SizedBox(height: 10),
          Text(L.t('Destination City'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 6),
          _dropdown(hint: L.t('Select destination city'), icon: Icons.location_on, iconColor: Colors.green, value: _end, nodes: nodes, onChanged: (v) => setState(() => _end = v), cs: cs),
          const SizedBox(height: 24),
          _loading ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _findPath,
                  style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: Icon(_algo == 'Compare' ? Icons.compare_arrows : Icons.directions, size: 22),
                  label: Text(L.t(_algo == 'Compare' ? 'Compare Algorithms' : 'Find Shortest Path'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
          const SizedBox(height: 16),
          _algoCard(cs),
          const SizedBox(height: 12),
          _complexityCard(cs),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildDrawer(ColorScheme cs) => Drawer(
    child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          const Icon(Icons.route, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(L.t('Smart Route Finder'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(L.t('ELE253 – DSA Project'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ),
      _drawerItem(Icons.home, L.t('Home'), () => Navigator.pop(context)),
      _drawerItem(Icons.analytics, L.t('Performance Benchmark'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const BenchmarkPage())); }),
      _drawerItem(Icons.school, L.t('Complexity Analysis'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplexityPage())); }),
      const Divider(),
      _drawerItem(Icons.edit, L.t('Graph Editor'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => GraphEditorPage(graph: _graph, onChanged: () => setState(() {})))); }),
      const Divider(),
      _drawerItem(Icons.info, L.t('About'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())); }),
    ]),
  );

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) => ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);

  Widget _algoSelector(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      for (final a in ['Dijkstra', 'Bellman-Ford', 'Compare'])
        Expanded(child: GestureDetector(
          onTap: () => setState(() => _algo = a),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: _algo == a ? cs.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
            child: Text(a == 'Compare' ? L.t('Compare') : a, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _algo == a ? cs.onPrimary : cs.onSurfaceVariant)),
          ),
        )),
    ]),
  );

  Widget _statsRow(ColorScheme cs) => Row(children: [
    _statCard(L.t('Cities'), '${_graph.nodeCount}', Icons.location_city, Colors.blue, cs),
    const SizedBox(width: 8),
    _statCard(L.t('Roads'), '${_graph.edgeCount}', Icons.alt_route, Colors.green, cs),
    const SizedBox(width: 8),
    _statCard(L.t('Algorithm'), _algo == 'Compare' ? L.t('Both') : _algo.split('-')[0], Icons.memory, Colors.purple, cs),
  ]);

  Widget _statCard(String label, String value, IconData icon, Color color, ColorScheme cs) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 20), const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
      ])),
  );

  Widget _dropdown({required String hint, required IconData icon, required Color iconColor, required String? value, required List<String> nodes, required ValueChanged<String?> onChanged, required ColorScheme cs}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.primary, width: 1.5),
            boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 20), const SizedBox(width: 8),
          Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            hint: Text(hint, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
            value: value, isExpanded: true, dropdownColor: cs.surface,
            items: nodes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ))),
        ]),
      );



  Widget _algoCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: cs.primaryContainer.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.info_outline, size: 15, color: cs.primary), const SizedBox(width: 6),
        Text(L.t('How it works'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
      ]),
      const SizedBox(height: 6),
      Text(L.t(_algo == 'Bellman-Ford'
          ? 'Bellman-Ford relaxes all edges V-1 times using dynamic programming. It handles negative weights and detects negative cycles.'
          : 'Dijkstra\'s greedy algorithm explores nodes by increasing distance to guarantee the global shortest path for non-negative weights.'),
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5)),
    ]),
  );

  Widget _complexityCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _cx(L.t('Time'), _algo == 'Bellman-Ford' ? 'O(V·E)' : 'O(V²)', cs.primary),
      _cx(L.t('Space'), _algo == 'Bellman-Ford' ? 'O(V)' : 'O(V+E)', Colors.green),
      _cx('V', '${_graph.nodeCount} ${L.t('cities')}', Colors.orange),
      _cx('E', '${_graph.edgeCount} ${L.t('roads')}', Colors.purple),
    ]),
  );

  Widget _cx(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
    Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  ]);
}