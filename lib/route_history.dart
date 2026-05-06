// ============================================================
// route_history.dart — Search History Model
// ELE253 – Data Structures and Algorithms
// ============================================================

class RouteHistory {
  final String start;
  final String end;
  final int distance;
  final int hops;
  final List<String> path;
  final DateTime timestamp;

  RouteHistory({
    required this.start,
    required this.end,
    required this.distance,
    required this.hops,
    required this.path,
    required this.timestamp,
  });

  String get timeLabel {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get dateLabel {
    final d = timestamp.day.toString().padLeft(2, '0');
    final mo = timestamp.month.toString().padLeft(2, '0');
    return '$d/$mo/${timestamp.year}';
  }
}