import 'package:flutter/material.dart';
import 'graph.dart';
import 'dijkstra.dart';
import 'app_locale.dart';

class MapPage extends StatefulWidget {
  final Graph graph;
  final RouteResult result;
  final String start;
  final String end;
  const MapPage({super.key, required this.graph, required this.result, required this.start, required this.end});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _showWeights = true;
  bool _showAllDist = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('Route Map'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _toggle(L.t('Show Weights'), _showWeights, (v) => setState(() => _showWeights = v), cs),
            const SizedBox(width: 8),
            _toggle(L.t('Show All Distances'), _showAllDist, (v) => setState(() => _showAllDist = v), cs),
          ])),
        Expanded(child: AnimatedBuilder(animation: _animCtrl,
          builder: (_, __) => CustomPaint(
            painter: _MapPainter(graph: widget.graph, result: widget.result, start: widget.start, end: widget.end,
                progress: _animCtrl.value, showWeights: _showWeights, showAllDist: _showAllDist, isDark: isDark, cs: cs),
            size: Size.infinite,
          ))),
        Container(padding: const EdgeInsets.all(14), color: cs.surface,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _legend(cs.primary, widget.start), _legend(Colors.green, widget.end),
            _legend(Colors.orange, '${widget.result.distance} km'),
            _legend(Colors.purple, widget.result.algorithmName),
          ])),
      ]),
    );
  }

  Widget _toggle(String label, bool val, ValueChanged<bool> onChanged, ColorScheme cs) => Expanded(
    child: GestureDetector(onTap: () => onChanged(!val),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: val ? cs.primary.withOpacity(0.1) : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: val ? cs.primary : cs.outlineVariant)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: val ? cs.primary : cs.onSurfaceVariant)))));

  Widget _legend(Color c, String t) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4), Text(t, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  ]);
}

class _MapPainter extends CustomPainter {
  final Graph graph;
  final RouteResult result;
  final String start;
  final String end;
  final double progress;
  final bool showWeights;
  final bool showAllDist;
  final bool isDark;
  final ColorScheme cs;

  _MapPainter({required this.graph, required this.result, required this.start, required this.end,
      required this.progress, required this.showWeights, required this.showAllDist, required this.isDark, required this.cs});

  static const Map<String, Offset> _pos = {
    'Cairo': Offset(0.50, 0.21), 'Giza': Offset(0.37, 0.27),
    'Alexandria': Offset(0.17, 0.09), 'Suez': Offset(0.65, 0.19),
    'Ismailia': Offset(0.60, 0.13), 'Port Said': Offset(0.55, 0.05),
    'Tanta': Offset(0.30, 0.14), 'Fayoum': Offset(0.30, 0.38),
    'Minya': Offset(0.33, 0.50), 'Assiut': Offset(0.35, 0.60),
    'Sohag': Offset(0.40, 0.68), 'Luxor': Offset(0.45, 0.78),
    'Aswan': Offset(0.50, 0.90), 'Marsa Matruh': Offset(0.05, 0.15),
  };

  Offset _getPos(String name, Size size) {
    final p = _pos[name];
    if (p != null) return Offset(p.dx * size.width, p.dy * size.height);
    final i = graph.getNodes().indexOf(name);
    return Offset(((i * 137) % 80 + 10) / 100 * size.width, ((i * 97) % 80 + 10) / 100 * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()..color = (isDark ? Colors.white24 : Colors.grey.shade300)..strokeWidth = 1.5;
    final pathPaint = Paint()..color = Colors.orange..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    final allEdges = graph.getAllEdges();

    for (final e in allEdges) {
      final from = _getPos(e['from'] as String, size);
      final to = _getPos(e['to'] as String, size);
      canvas.drawLine(from, to, edgePaint);
      if (showWeights) {
        final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
        final tp = TextPainter(text: TextSpan(text: '${e['weight']}', style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : Colors.grey.shade600)),
            textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy - tp.height / 2));
      }
    }

    if (result.pathFound) {
      final pathLen = result.path.length;
      final visibleEdges = (progress * (pathLen - 1)).floor();
      for (int i = 0; i < visibleEdges && i < pathLen - 1; i++) {
        canvas.drawLine(_getPos(result.path[i], size), _getPos(result.path[i + 1], size), pathPaint);
      }
      if (visibleEdges < pathLen - 1) {
        final frac = (progress * (pathLen - 1)) - visibleEdges;
        final from = _getPos(result.path[visibleEdges], size);
        final to = _getPos(result.path[visibleEdges + 1], size);
        canvas.drawLine(from, Offset(from.dx + (to.dx - from.dx) * frac, from.dy + (to.dy - from.dy) * frac), pathPaint);
      }
    }

    for (final node in graph.getNodes()) {
      final pos = _getPos(node, size);
      final isOnPath = result.path.contains(node);
      final isStart = node == start;
      final isEnd = node == end;
      final color = isStart ? cs.primary : isEnd ? Colors.green : isOnPath ? Colors.orange : (isDark ? Colors.white38 : Colors.grey);
      final radius = isStart || isEnd ? 14.0 : isOnPath ? 11.0 : 8.0;

      canvas.drawCircle(pos, radius, Paint()..color = color);
      canvas.drawCircle(pos, radius, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

      final tp = TextPainter(text: TextSpan(text: node, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + radius + 4));

      if (showAllDist && result.allDistances.containsKey(node) && result.allDistances[node]! < 999999) {
        final dp = TextPainter(text: TextSpan(text: '${result.allDistances[node]}km', style: TextStyle(fontSize: 8, color: cs.primary)),
            textDirection: TextDirection.ltr)..layout();
        dp.paint(canvas, Offset(pos.dx - dp.width / 2, pos.dy - radius - 14));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.progress != progress || old.showWeights != showWeights || old.showAllDist != showAllDist;
}