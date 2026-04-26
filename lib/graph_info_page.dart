import 'package:flutter/material.dart';
import 'graph.dart';

class GraphInfoPage extends StatelessWidget {
  final Graph graph;

  const GraphInfoPage({super.key, required this.graph});

  @override
  Widget build(BuildContext context) {
    final heaviest = graph.getHeaviestEdges(5);
    final nodes = graph.getNodes()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A4A),
        title: const Text(
          'Graph Information',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _card('Graph Properties', [
              _row('Type', 'Weighted undirected'),
              _row('Nodes (V)', '${graph.nodeCount} cities'),
              _row('Edges (E)', '${graph.edgeCount} roads'),
              _row('Connected', graph.isConnected ? 'Yes' : 'No'),
              _row('Time complexity', 'O(V²)'),
              _row('Space complexity', 'O(V + E)'),
              _row('Representation', 'Adjacency list'),
            ]),
            const SizedBox(height: 14),

            _card(
              'Heaviest Roads (Top 5)',
              heaviest
                  .map((e) => _row(
                        '${e["from"]} → ${e["to"]}',
                        '${e["weight"]} km',
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),

            _card(
              'City Connectivity',
              nodes
                  .map((c) => _row(
                        c,
                        '${graph.degree(c)} connection'
                        '${graph.degree(c) != 1 ? "s" : ""}',
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Dijkstra?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1B2A4A),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Non-negative weights — greedy approach guarantees '
                    'the globally optimal solution.\n\n'
                    '• Single-source — shortest path from one start city '
                    'to one destination.\n\n'
                    '• O(V²) with simple array is efficient for small '
                    'graphs (V=14). For V>1000 a min-heap gives '
                    'O((V+E) log V).\n\n'
                    '• Adjacency List over Matrix because the graph is '
                    'sparse (E=16 << V²=196), saving memory.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444444),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}