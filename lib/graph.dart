class Graph {
  final Map<String, Map<String, int>> adjList = {};

  void addEdge(String u, String v, int weight) {
    adjList.putIfAbsent(u, () => {});
    adjList.putIfAbsent(v, () => {});
    adjList[u]![v] = weight;
    adjList[v]![u] = weight;
  }

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

  List<Map<String, dynamic>> getHeaviestEdges(int n) {
    final edges = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final u in adjList.keys) {
      for (final entry in adjList[u]!.entries) {
        final key = ([u, entry.key]..sort()).join('-');
        if (!seen.contains(key)) {
          seen.add(key);
          edges.add({
            'from': u,
            'to': entry.key,
            'weight': entry.value,
          });
        }
      }
    }
    edges.sort(
      (a, b) => (b['weight'] as int).compareTo(a['weight'] as int),
    );
    return edges.take(n).toList();
  }
}