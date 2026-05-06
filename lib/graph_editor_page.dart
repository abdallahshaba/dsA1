import 'package:flutter/material.dart';
import 'graph.dart';
import 'app_locale.dart';

class GraphEditorPage extends StatefulWidget {
  final Graph graph;
  final VoidCallback onChanged;
  const GraphEditorPage({super.key, required this.graph, required this.onChanged});
  @override
  State<GraphEditorPage> createState() => _GraphEditorPageState();
}

class _GraphEditorPageState extends State<GraphEditorPage> {
  final _cityCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _edgeFrom;
  String? _edgeTo;

  @override
  void dispose() { _cityCtrl.dispose(); _weightCtrl.dispose(); super.dispose(); }

  void _addCity() {
    final name = _cityCtrl.text.trim();
    if (name.isEmpty) { _snack(L.t('Enter a city name')); return; }
    if (widget.graph.adjList.containsKey(name)) { _snack(L.t('City already exists')); return; }
    setState(() { widget.graph.adjList.putIfAbsent(name, () => {}); _cityCtrl.clear(); });
    widget.onChanged();
    _snack('${L.t('Added')} $name');
  }

  void _addEdge() {
    if (_edgeFrom == null || _edgeTo == null) { _snack(L.t('Select both cities')); return; }
    if (_edgeFrom == _edgeTo) { _snack(L.t('Must be different cities')); return; }
    final w = int.tryParse(_weightCtrl.text) ?? 0;
    if (w <= 0) { _snack(L.t('Enter a valid positive weight')); return; }
    setState(() { widget.graph.addEdge(_edgeFrom!, _edgeTo!, w); _weightCtrl.clear(); });
    widget.onChanged();
    _snack('${L.t('Road added')}: $_edgeFrom ↔ $_edgeTo ($w km)');
  }

  void _removeCity(String city) {
    setState(() { widget.graph.removeNode(city); if (_edgeFrom == city) _edgeFrom = null; if (_edgeTo == city) _edgeTo = null; });
    widget.onChanged();
  }

  void _removeEdge(String u, String v) { setState(() => widget.graph.removeEdge(u, v)); widget.onChanged(); }

  void _resetGraph() {
    setState(() {
      widget.graph.clear();
      widget.graph.addEdge('Cairo', 'Giza', 20); widget.graph.addEdge('Cairo', 'Alexandria', 220);
      widget.graph.addEdge('Cairo', 'Suez', 134); widget.graph.addEdge('Cairo', 'Ismailia', 120);
      widget.graph.addEdge('Cairo', 'Aswan', 900); widget.graph.addEdge('Giza', 'Fayoum', 100);
      widget.graph.addEdge('Alexandria', 'Tanta', 94); widget.graph.addEdge('Alexandria', 'Marsa Matruh', 290);
      widget.graph.addEdge('Tanta', 'Cairo', 95); widget.graph.addEdge('Fayoum', 'Minya', 170);
      widget.graph.addEdge('Minya', 'Assiut', 120); widget.graph.addEdge('Assiut', 'Sohag', 115);
      widget.graph.addEdge('Sohag', 'Luxor', 160); widget.graph.addEdge('Luxor', 'Aswan', 215);
      widget.graph.addEdge('Suez', 'Ismailia', 78); widget.graph.addEdge('Ismailia', 'Port Said', 85);
      _edgeFrom = null; _edgeTo = null;
    });
    widget.onChanged();
    _snack(L.t('Graph reset to default'));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nodes = widget.graph.getNodes()..sort();
    final edges = widget.graph.getAllEdges();
    return Scaffold(
      appBar: AppBar(title: Text(L.t('Graph Editor'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.restore), tooltip: L.t('Reset'), onPressed: _resetGraph)]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            _stat(L.t('Cities'), '${widget.graph.nodeCount}', Icons.location_city, cs.primary, cs),
            const SizedBox(width: 8),
            _stat(L.t('Roads'), '${widget.graph.edgeCount}', Icons.alt_route, Colors.green, cs),
            const SizedBox(width: 8),
            _stat(L.t('Density'), widget.graph.density.toStringAsFixed(2), Icons.grain, Colors.purple, cs),
          ]),
          const SizedBox(height: 16),
          _section(L.t('Add City'), cs, Row(children: [
            Expanded(child: TextField(controller: _cityCtrl,
                decoration: InputDecoration(hintText: L.t('City name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addCity, style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(L.t('Add'))),
          ])),
          const SizedBox(height: 12),
          _section(L.t('Add Road'), cs, Column(children: [
            Row(children: [
              Expanded(child: _dd(L.t('From'), _edgeFrom, nodes, (v) => setState(() => _edgeFrom = v), cs)),
              const SizedBox(width: 8),
              Expanded(child: _dd(L.t('To'), _edgeTo, nodes, (v) => setState(() => _edgeTo = v), cs)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: _weightCtrl, keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: L.t('Distance (km)'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addEdge, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(L.t('Add'))),
            ]),
          ])),
          const SizedBox(height: 16),
          Text('${L.t('Cities')} (${nodes.length})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: nodes.map((c) => Chip(
            label: Text(c, style: const TextStyle(fontSize: 12)), deleteIcon: const Icon(Icons.close, size: 16), onDeleted: () => _removeCity(c),
          )).toList()),
          const SizedBox(height: 16),
          Text('${L.t('Roads')} (${edges.length})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 8),
          ...edges.map((e) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: cs.outlineVariant)),
            child: Row(children: [
              Expanded(child: Text('${e['from']} ↔ ${e['to']}', style: const TextStyle(fontSize: 13))),
              Text('${e['weight']} km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.primary)),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => _removeEdge(e['from'], e['to']), child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400)),
            ]))),
          const SizedBox(height: 20),
        ])),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color, ColorScheme cs) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10))])));

  Widget _section(String title, ColorScheme cs, Widget child) => Container(padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)), const SizedBox(height: 10), child]));

  Widget _dd(String hint, String? val, List<String> items, ValueChanged<String?> onChanged, ColorScheme cs) =>
      DropdownButtonFormField<String>(value: val, isExpanded: true,
        decoration: InputDecoration(labelText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged);
}
