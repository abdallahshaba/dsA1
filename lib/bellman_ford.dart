import 'graph.dart';
import 'dijkstra.dart';

class BellmanFord {
  static RouteResult shortestPath(Graph graph, String start, String end) {
    final sw = Stopwatch()..start();
    int relaxed = 0;

    final nodes = graph.getNodes();
    final Map<String, int> dist = {};
    final Map<String, String?> prev = {};

    for (final node in nodes) {
      dist[node] = 999999;
      prev[node] = null;
    }
    dist[start] = 0;

    // Collect all directed edges (undirected = 2 directed)
    final edges = <List<dynamic>>[];
    final seen = <String>{};
    for (final u in graph.adjList.keys) {
      for (final entry in graph.adjList[u]!.entries) {
        final key = '${u}__${entry.key}';
        if (!seen.contains(key)) {
          seen.add(key);
          edges.add([u, entry.key, entry.value]);
        }
      }
    }

    // Relax all edges V-1 times
    bool updated = false;
    for (int i = 0; i < nodes.length - 1; i++) {
      updated = false;
      for (final edge in edges) {
        final u = edge[0] as String;
        final v = edge[1] as String;
        final w = edge[2] as int;
        relaxed++;
        if (dist[u]! < 999999 && dist[u]! + w < dist[v]!) {
          dist[v] = dist[u]! + w;
          prev[v] = u;
          updated = true;
        }
      }
      if (!updated) break;
    }

    // Detect negative cycles
    bool hasNegCycle = false;
    if (updated) {
      for (final edge in edges) {
        final u = edge[0] as String;
        final v = edge[1] as String;
        final w = edge[2] as int;
        if (dist[u]! < 999999 && dist[u]! + w < dist[v]!) {
          hasNegCycle = true;
          break;
        }
      }
    }
    sw.stop();

    // Reconstruct path
    final path = <String>[];
    String? temp = end;
    final visited = <String>{};
    while (temp != null && !visited.contains(temp)) {
      visited.add(temp);
      path.insert(0, temp);
      temp = prev[temp];
    }

    final found = !hasNegCycle &&
        path.isNotEmpty &&
        path.first == start &&
        dist[end]! < 999999;

    return RouteResult(
      path: found ? path : [],
      distance: found ? dist[end]! : -1,
      pathFound: found,
      hops: found ? path.length - 1 : 0,
      allDistances: Map<String, int>.from(dist),
      algorithmName: 'Bellman-Ford',
      executionMicroseconds: sw.elapsedMicroseconds,
      nodesVisited: nodes.length,
      edgesRelaxed: relaxed,
      hasNegativeCycle: hasNegCycle,
    );
  }
}
