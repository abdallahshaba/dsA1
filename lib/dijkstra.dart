import 'graph.dart';

class RouteResult {
  final List<String> path;
  final int distance;
  final bool pathFound;
  final int hops;
  final Map<String, int> allDistances;
  final String algorithmName;
  final int executionMicroseconds;
  final int nodesVisited;
  final int edgesRelaxed;
  final bool hasNegativeCycle;

  const RouteResult({
    required this.path,
    required this.distance,
    required this.pathFound,
    required this.hops,
    required this.allDistances,
    this.algorithmName = 'Dijkstra',
    this.executionMicroseconds = 0,
    this.nodesVisited = 0,
    this.edgesRelaxed = 0,
    this.hasNegativeCycle = false,
  });
}

class Dijkstra {
  static RouteResult shortestPath(
    Graph graph,
    String start,
    String end, {
    int? maxHops,
  }) {
    final sw = Stopwatch()..start();
    int visited = 0;
    int relaxed = 0;

    final Map<String, int> dist = {};
    final Map<String, String?> prev = {};
    final Set<String> done = {};
    final Map<String, int> hops = {};

    for (final node in graph.adjList.keys) {
      dist[node] = 999999;
      prev[node] = null;
      hops[node] = 0;
    }
    dist[start] = 0;

    while (done.length != graph.adjList.length) {
      String? current;
      int minDist = 999999;   // الكود دا بيشوف اي اقرب مدينة   
      for (final node in dist.keys) {
        if (!done.contains(node) && dist[node]! < minDist) {
          minDist = dist[node]!;
          current = node;
        }
      }
      if (current == null) break;
      done.add(current);
      visited++;

      for (final nb in graph.adjList[current]!.keys) {
        final newDist = dist[current]! + graph.adjList[current]![nb]!;
        final newHops = hops[current]! + 1;
        if (maxHops != null && newHops > maxHops) continue;
        relaxed++;
        if (newDist < dist[nb]!) {
          dist[nb] = newDist;
          prev[nb] = current;
          hops[nb] = newHops;
        }
      }
    }
    sw.stop();

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
      algorithmName: 'Dijkstra',
      executionMicroseconds: sw.elapsedMicroseconds,
      nodesVisited: visited,
      edgesRelaxed: relaxed,
    );
  }
}