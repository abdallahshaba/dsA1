import 'dart:math';

class Graph {
  final Map<String, Map<String, int>> adjList = {};

  void addEdge(String u, String v, int weight) {
    adjList.putIfAbsent(u, () => {});
    adjList.putIfAbsent(v, () => {});
    adjList[u]![v] = weight;
    adjList[v]![u] = weight;
  }

  void removeEdge(String u, String v) {
    adjList[u]?.remove(v);
    adjList[v]?.remove(u);
  }

  void removeNode(String node) {
    adjList.remove(node);
    for (final neighbors in adjList.values) {
      neighbors.remove(node);
    }
  }

  void clear() => adjList.clear();

  List<String> getNodes() => List<String>.from(adjList.keys);

  int get nodeCount => adjList.length;

  int get edgeCount {
    int total = 0;
    for (final n in adjList.values) {
      total += n.length;
    }
    return total ~/ 2;
  }

  bool hasEdge(String u, String v) {
    return adjList.containsKey(u) && adjList[u]!.containsKey(v);
  }

  int getWeight(String u, String v) {
    return hasEdge(u, v) ? adjList[u]![v]! : -1;
  }

  int degree(String node) => adjList[node]?.length ?? 0;

  double get density {
    final v = nodeCount;
    if (v <= 1) return 0;
    return (2.0 * edgeCount) / (v * (v - 1));
  }

  bool get isConnected {
    if (adjList.isEmpty) return true;
    final visited = <String>{};
    final queue = <String>[adjList.keys.first];
    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      if (visited.contains(node)) continue;
      visited.add(node);
      for (final nb in adjList[node]!.keys) {
        if (!visited.contains(nb)) queue.add(nb);
      }
    }
    return visited.length == adjList.length;
  }

  Graph clone() {
    final g = Graph();
    for (final u in adjList.keys) {
      for (final entry in adjList[u]!.entries) {
        g.adjList.putIfAbsent(u, () => {});
        g.adjList[u]![entry.key] = entry.value;
      }
    }
    return g;
  }

  List<Map<String, dynamic>> getAllEdges() {
    final edges = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final u in adjList.keys) {
      for (final entry in adjList[u]!.entries) {
        final key = ([u, entry.key]..sort()).join('-');
        if (!seen.contains(key)) {
          seen.add(key);
          edges.add({'from': u, 'to': entry.key, 'weight': entry.value});
        }
      }
    }
    return edges;
  }

  List<Map<String, dynamic>> getHeaviestEdges(int n) {
    final edges = getAllEdges();
    edges.sort(
      (a, b) => (b['weight'] as int).compareTo(a['weight'] as int),
    );
    return edges.take(n).toList();
  }

  /// Generate a random connected graph for benchmarking
  static Graph generateRandom(int nodeCount, int edgeCount,
      {int maxWeight = 100}) {
    final g = Graph();
    final random = Random();
    for (int i = 0; i < nodeCount; i++) {
      g.adjList.putIfAbsent('N$i', () => {});
    }
    final nodes = g.getNodes();
    int added = 0;
    // Ensure connectivity
    for (int i = 1; i < nodeCount; i++) {
      g.addEdge(nodes[i - 1], nodes[i], random.nextInt(maxWeight) + 1);
      added++;
    }
    // Random extra edges
    int attempts = 0;
    while (added < edgeCount && attempts < edgeCount * 10) {
      attempts++;
      final u = nodes[random.nextInt(nodeCount)];
      final v = nodes[random.nextInt(nodeCount)];
      if (u != v && !g.hasEdge(u, v)) {
        g.addEdge(u, v, random.nextInt(maxWeight) + 1);
        added++;
      }
    }
    return g;
  }
}