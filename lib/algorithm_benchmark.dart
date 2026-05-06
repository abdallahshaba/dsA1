import 'graph.dart';
import 'dijkstra.dart';
import 'bellman_ford.dart';

class BenchmarkEntry {
  final int nodeCount;
  final int edgeCount;
  final int dijkstraTimeMicro;
  final int bellmanTimeMicro;
  final int dijkstraRelaxations;
  final int bellmanRelaxations;

  const BenchmarkEntry({
    required this.nodeCount,
    required this.edgeCount,
    required this.dijkstraTimeMicro,
    required this.bellmanTimeMicro,
    required this.dijkstraRelaxations,
    required this.bellmanRelaxations,
  });
}

class AlgorithmBenchmark {
  /// Run both algorithms on random graphs of increasing size
  static List<BenchmarkEntry> runScalabilityTest({
    List<int> sizes = const [10, 25, 50, 100, 200, 400],
    int runsPerSize = 3,
  }) {
    final results = <BenchmarkEntry>[];

    for (final n in sizes) {
      final edgeCount = (n * 1.5).toInt().clamp(n - 1, n * (n - 1) ~/ 2);
      int totalDijkTime = 0;
      int totalBFTime = 0;
      int totalDijkRelax = 0;
      int totalBFRelax = 0;

      for (int r = 0; r < runsPerSize; r++) {
        final g = Graph.generateRandom(n, edgeCount);
        final nodes = g.getNodes();
        final start = nodes.first;
        final end = nodes.last;

        final dResult = Dijkstra.shortestPath(g, start, end);
        final bResult = BellmanFord.shortestPath(g, start, end);

        totalDijkTime += dResult.executionMicroseconds;
        totalBFTime += bResult.executionMicroseconds;
        totalDijkRelax += dResult.edgesRelaxed;
        totalBFRelax += bResult.edgesRelaxed;
      }

      results.add(BenchmarkEntry(
        nodeCount: n,
        edgeCount: edgeCount,
        dijkstraTimeMicro: totalDijkTime ~/ runsPerSize,
        bellmanTimeMicro: totalBFTime ~/ runsPerSize,
        dijkstraRelaxations: totalDijkRelax ~/ runsPerSize,
        bellmanRelaxations: totalBFRelax ~/ runsPerSize,
      ));
    }
    return results;
  }
}
