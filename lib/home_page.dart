import 'package:flutter/material.dart';
import 'graph.dart';
import 'dijkstra.dart';
import 'route_history.dart';
import 'result_page.dart';
import 'history_page.dart';
import 'graph_info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Graph _graph = Graph();
  String? _start;
  String? _end;
  int? _maxHops;
  bool _loading = false;
  final List<RouteHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

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
    if (_start == null || _end == null) {
      _snack('Please select both cities.');
      return;
    }
    if (_start == _end) {
      _snack('Start and destination must be different.');
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final result = Dijkstra.shortestPath(
      _graph,
      _start!,
      _end!,
      maxHops: _maxHops,
    );

    if (result.pathFound) {
      _history.insert(
        0,
        RouteHistory(
          start: _start!,
          end: _end!,
          distance: result.distance,
          hops: result.hops,
          path: result.path,
          timestamp: DateTime.now(),
        ),
      );
    }

    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => ResultPage(
          result: result,
          graph: _graph,
          start: _start!,
          end: _end!,
          history: _history,
        ),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _swap() => setState(() {
        final tmp = _start;
        _start = _end;
        _end = tmp;
      });

  @override
  Widget build(BuildContext context) {
    final nodes = _graph.getNodes()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A4A),
        title: const Text(
          'Smart Route Finder',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryPage(history: _history),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GraphInfoPage(graph: _graph),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Icon(Icons.map_outlined,
                size: 64, color: Color(0xFF1A73E8)),
            const SizedBox(height: 8),
            const Text(
              'Find the shortest route between Egyptian cities',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Stats
            _statsRow(),
            const SizedBox(height: 24),

            // Start
            _label('Starting City'),
            const SizedBox(height: 6),
            _dropdown(
              hint: 'Select starting city',
              icon: Icons.my_location,
              iconColor: const Color(0xFF1A73E8),
              value: _start,
              nodes: nodes,
              onChanged: (v) => setState(() => _start = v),
            ),
            const SizedBox(height: 10),

            // Swap
            Center(
              child: GestureDetector(
                onTap: _swap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1A73E8),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: Color(0xFF1A73E8),
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // End
            _label('Destination City'),
            const SizedBox(height: 6),
            _dropdown(
              hint: 'Select destination city',
              icon: Icons.location_on,
              iconColor: Colors.green,
              value: _end,
              nodes: nodes,
              onChanged: (v) => setState(() => _end = v),
            ),
            const SizedBox(height: 16),

            // Max hops
            _label('Max Stops (optional)'),
            const SizedBox(height: 6),
            _hopsRow(),
            const SizedBox(height: 28),

            // Button
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _findPath,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.directions, size: 22),
                    label: const Text(
                      'Find Shortest Path',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            // Info cards
            _algoCard(),
            const SizedBox(height: 12),
            _complexityCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF333333),
        ),
      );

  Widget _statsRow() {
    return Row(
      children: [
        _statCard('Cities', '${_graph.nodeCount}',
            Icons.location_city, Colors.blue),
        const SizedBox(width: 8),
        _statCard('Roads', '${_graph.edgeCount}',
            Icons.alt_route, Colors.green),
        const SizedBox(width: 8),
        _statCard('Algorithm', 'Dijkstra',
            Icons.memory, Colors.purple),
      ],
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required IconData icon,
    required Color iconColor,
    required String? value,
    required List<String> nodes,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A73E8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text(
                  hint,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                value: value,
                isExpanded: true,
                items: nodes
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hopsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _maxHops == null ? 'No limit' : '$_maxHops max stops',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          _hopChip('Any', _maxHops == null,
              () => setState(() => _maxHops = null)),
          const SizedBox(width: 4),
          for (final h in [1, 2, 3, 4]) ...[
            _hopChip(
              '$h',
              _maxHops == h,
              () => setState(() => _maxHops = h),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  Widget _hopChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A73E8)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _algoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 15, color: Color(0xFF1A73E8)),
              SizedBox(width: 6),
              Text(
                'How it works',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1B2A4A),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'The city network is a weighted undirected graph stored as '
            'an adjacency list. Dijkstra\'s greedy algorithm explores '
            'nodes by increasing distance to guarantee the global '
            'shortest path for non-negative weights.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF444444),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _complexityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _cx('Time', 'O(V²)', Colors.blue),
          _cx('Space', 'O(V+E)', Colors.green),
          _cx('V', '14 cities', Colors.orange),
          _cx('E', '16 roads', Colors.purple),
        ],
      ),
    );
  }

  Widget _cx(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}