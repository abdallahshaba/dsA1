import 'graph.dart';

class RouteResult {
  final List<String> path;
  final int distance;
  final bool pathFound;
  final int hops;
  final Map<String, int> allDistances;

  const RouteResult({
    required this.path,
    required this.distance,
    required this.pathFound,
    required this.hops,
    required this.allDistances,
  });
}

class Dijkstra {
  static RouteResult shortestPath(
    Graph graph,
    String start,
    String end, {
    int? maxHops,
  }) {
    final Map<String, int> dist = {};
    final Map<String, String?> prev = {};
    final Set<String> visited = {};
    final Map<String, int> hops = {};

    // Initialize
    for (final node in graph.adjList.keys) {
      dist[node] = 999999;
      prev[node] = null;
      hops[node] = 0;
    }
    dist[start] = 0;

    // Main loop
    while (visited.length != graph.adjList.length) {
      // Pick unvisited node with smallest distance
      String? current;
      int minDist = 999999;
      for (final node in dist.keys) {
        if (!visited.contains(node) && dist[node]! < minDist) {
          minDist = dist[node]!;
          current = node;
        }
      }

      if (current == null) break;
      visited.add(current);

      // Relax edges
      for (final nb in graph.adjList[current]!.keys) {
        final newDist = dist[current]! + graph.adjList[current]![nb]!;
        final newHops = hops[current]! + 1;

        if (maxHops != null && newHops > maxHops) continue;

        if (newDist < dist[nb]!) {
          dist[nb] = newDist;
          prev[nb] = current;
          hops[nb] = newHops;
        }
      }
    }

    // Reconstruct path
    final path = <String>[];
    String? temp = end;
    while (temp != null) {
      path.insert(0, temp);
      temp = prev[temp];
    }

    final found =
        path.isNotEmpty && path.first == start && dist[end]! < 999999;

    return RouteResult(
      path: found ? path : [],
      distance: found ? dist[end]! : -1,
      pathFound: found,
      hops: found ? path.length - 1 : 0,
      allDistances: Map<String, int>.from(dist),
    );
  }
}