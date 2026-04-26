import 'package:flutter/material.dart';
import 'graph.dart';
import 'dijkstra.dart';
import 'route_history.dart';
import 'map_page.dart';

class ResultPage extends StatelessWidget {
  final RouteResult result;
  final Graph graph;
  final String start;
  final String end;
  final List<RouteHistory> history;

  const ResultPage({
    super.key,
    required this.result,
    required this.graph,
    required this.start,
    required this.end,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A4A),
        title: const Text(
          'Route Result',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (result.pathFound)
            IconButton(
              icon: const Icon(Icons.map, color: Colors.white),
              onPressed: () => _goToMap(context),
            ),
        ],
      ),
      body: result.pathFound
          ? _buildSuccess(context)
          : _buildNoPath(context),
    );
  }

  void _goToMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPage(
          graph: graph,
          result: result,
          start: start,
          end: end,
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final directRoad = graph.getWeight(start, end);
    final saved = directRoad > 0 ? directRoad - result.distance : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _distCard(),
          const SizedBox(height: 14),

          if (directRoad > 0) ...[
            _compareCard(directRoad, saved),
            const SizedBox(height: 14),
          ],

          _journeySummary(),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${result.hops} stop${result.hops != 1 ? "s" : ""}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _timeline(),
          const SizedBox(height: 20),

          _allDistances(),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () => _goToMap(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.map),
            label: const Text(
              'View on Map',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.search),
            label: const Text('Search Again'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _distCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A4A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shortest Distance',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.distance} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.route, color: Colors.white54, size: 30),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${result.hops} stop${result.hops != 1 ? "s" : ""}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compareCard(int directRoad, int saved) {
    final better = result.distance < directRoad;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: better ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: better
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            better ? Icons.trending_down : Icons.compare_arrows,
            color: better ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              better
                  ? 'Dijkstra saved $saved km vs direct ($directRoad km)'
                  : 'Direct road: $directRoad km | This route: ${result.distance} km',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: better
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeySummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _cityChip(
              'From', start, Icons.my_location, const Color(0xFF1A73E8)),
          ),
          const Icon(Icons.arrow_forward_rounded,
              color: Colors.grey, size: 20),
          Expanded(
            child: _cityChip('To', end, Icons.flag, Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _cityChip(
      String label, String city, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(label,
            style:
                const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(
          city,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _timeline() {
    return Column(
      children: List.generate(result.path.length, (i) {
        final city = result.path[i];
        final isFirst = i == 0;
        final isLast = i == result.path.length - 1;
        final color = isFirst
            ? const Color(0xFF1A73E8)
            : isLast
                ? Colors.green
                : Colors.orange;
        final segDist =
            !isFirst ? graph.getWeight(result.path[i - 1], city) : -1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: color,
                    child: Icon(
                      isFirst
                          ? Icons.my_location
                          : isLast
                              ? Icons.flag
                              : Icons.circle,
                      color: Colors.white,
                      size: isFirst || isLast ? 15 : 8,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 6, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isFirst || isLast
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isFirst
                            ? const Color(0xFF1A73E8)
                            : isLast
                                ? Colors.green
                                : Colors.black87,
                      ),
                    ),
                    Text(
                      isFirst
                          ? 'Starting point'
                          : isLast
                              ? 'Destination'
                              : 'Intermediate stop',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isFirst && segDist > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$segDist km',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _allDistances() {
    final sorted = result.allDistances.entries
        .where((e) => e.value < 999999)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All distances from start',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...sorted.map((e) {
            final onPath = result.path.contains(e.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        onPath
                            ? Icons.circle
                            : Icons.circle_outlined,
                        size: 8,
                        color: onPath
                            ? const Color(0xFF1A73E8)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: onPath
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: onPath
                              ? const Color(0xFF1A73E8)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${e.value} km',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: onPath
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: onPath
                          ? const Color(0xFF1A73E8)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoPath(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wrong_location,
                size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'No Route Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No road connection exists between $start and $end.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 28,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}