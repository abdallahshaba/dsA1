import 'package:flutter/material.dart';
import 'graph.dart';
import 'dijkstra.dart';

class MapPage extends StatefulWidget {
  final Graph graph;
  final RouteResult result;
  final String start;
  final String end;

  const MapPage({
    super.key,
    required this.graph,
    required this.result,
    required this.start,
    required this.end,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showWeights = true;
  bool _showAllDist = false;

  static const Map<String, Offset> _pos = {
    'Cairo': Offset(0.50, 0.21),
    'Giza': Offset(0.37, 0.27),
    'Alexandria': Offset(0.17, 0.09),
    'Suez': Offset(0.65, 0.19),
    'Ismailia': Offset(0.66, 0.10),
    'Port Said': Offset(0.74, 0.02),
    'Tanta': Offset(0.30, 0.11),
    'Fayoum': Offset(0.31, 0.37),
    'Minya': Offset(0.40, 0.51),
    'Assiut': Offset(0.45, 0.61),
    'Sohag': Offset(0.47, 0.69),
    'Luxor': Offset(0.52, 0.77),
    'Aswan': Offset(0.55, 0.85),
    'Marsa Matruh': Offset(0.08, 0.04),
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A4A),
        title: Text(
          '${widget.start} → ${widget.end}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _showWeights ? Icons.label : Icons.label_off,
              color: Colors.white,
            ),
            tooltip: 'Toggle distances',
            onPressed: () =>
                setState(() => _showWeights = !_showWeights),
          ),
          IconButton(
            icon: Icon(
              _showAllDist
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white,
            ),
            tooltip: 'Show all distances',
            onPressed: () =>
                setState(() => _showAllDist = !_showAllDist),
          ),
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white),
            tooltip: 'Replay animation',
            onPressed: () {
              _ctrl.reset();
              _ctrl.forward();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _legend(),
          Expanded(
            child: LayoutBuilder(
              builder: (_, box) => AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CustomPaint(
                  size: Size(box.maxWidth, box.maxHeight),
                  painter: _MapPainter(
                    graph: widget.graph,
                    result: widget.result,
                    start: widget.start,
                    end: widget.end,
                    progress: _anim.value,
                    showWeights: _showWeights,
                    showAllDist: _showAllDist,
                  ),
                ),
              ),
            ),
          ),
          _bottomInfo(),
        ],
      ),
    );
  }

  Widget _legend() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _legLine(Colors.blueGrey.shade200, 'Road'),
          const SizedBox(width: 14),
          _legLine(const Color(0xFF1A73E8), 'Path', thick: true),
          const SizedBox(width: 14),
          _legDot(const Color(0xFF1A73E8), 'Start'),
          const SizedBox(width: 10),
          _legDot(Colors.green, 'End'),
          const SizedBox(width: 10),
          _legDot(Colors.orange, 'Via'),
        ],
      ),
    );
  }

  Widget _legLine(Color c, String label, {bool thick = false}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: thick ? 3.0 : 1.5,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _legDot(Color c, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _bottomInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _info('Distance', '${widget.result.distance} km'),
          _info('Stops', '${widget.result.hops}'),
          _info(
            'Path',
            widget.result.path.join(' → '),
            small: true,
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value, {bool small = false}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 10 : 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B2A4A),
          ),
        ),
      ],
    );
  }
}

// ── Custom Painter ──────────────────────────────────────

class _MapPainter extends CustomPainter {
  final Graph graph;
  final RouteResult result;
  final String start;
  final String end;
  final double progress;
  final bool showWeights;
  final bool showAllDist;

  static const Map<String, Offset> _pos = {
    'Cairo': Offset(0.50, 0.21),
    'Giza': Offset(0.37, 0.27),
    'Alexandria': Offset(0.17, 0.09),
    'Suez': Offset(0.65, 0.19),
    'Ismailia': Offset(0.66, 0.10),
    'Port Said': Offset(0.74, 0.02),
    'Tanta': Offset(0.30, 0.11),
    'Fayoum': Offset(0.31, 0.37),
    'Minya': Offset(0.40, 0.51),
    'Assiut': Offset(0.45, 0.61),
    'Sohag': Offset(0.47, 0.69),
    'Luxor': Offset(0.52, 0.77),
    'Aswan': Offset(0.55, 0.85),
    'Marsa Matruh': Offset(0.08, 0.04),
  };

  _MapPainter({
    required this.graph,
    required this.result,
    required this.start,
    required this.end,
    required this.progress,
    required this.showWeights,
    required this.showAllDist,
  });

  Offset _p(String city, Size size) {
    final o = _pos[city] ?? const Offset(0.5, 0.5);
    return Offset(o.dx * size.width, o.dy * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFDEEAFB),
    );

    final pathSet = <String>{};
    for (int i = 0; i < result.path.length - 1; i++) {
      pathSet.add('${result.path[i]}__${result.path[i + 1]}');
      pathSet.add('${result.path[i + 1]}__${result.path[i]}');
    }

    // Draw all base edges
    final basePaint = Paint()
      ..color = Colors.blueGrey.shade200
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final seen = <String>{};
    for (final u in graph.adjList.keys) {
      for (final entry in graph.adjList[u]!.entries) {
        final v = entry.key;
        final edgeKey = ([u, v]..sort()).join('__');
        if (seen.contains(edgeKey)) continue;
        seen.add(edgeKey);

        if (!_pos.containsKey(u) || !_pos.containsKey(v)) continue;
        final a = _p(u, size);
        final b = _p(v, size);

        if (!pathSet.contains('${u}__${v}')) {
          canvas.drawLine(a, b, basePaint);
        }

        if (showWeights) {
          _drawText(
            canvas,
            '${entry.value}km',
            Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 - 6),
            fontSize: 8.5,
            color: Colors.blueGrey.shade400,
          );
        }
      }
    }

    // Draw animated path edges
    if (result.pathFound) {
      final segs = result.path.length - 1;
      final pathPaint = Paint()
        ..color = const Color(0xFF1A73E8)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < segs; i++) {
        final segProgress =
            ((progress * segs) - i).clamp(0.0, 1.0);
        if (segProgress <= 0) continue;
        if (!_pos.containsKey(result.path[i]) ||
            !_pos.containsKey(result.path[i + 1])) continue;

        final a = _p(result.path[i], size);
        final b = _p(result.path[i + 1], size);
        final pt = Offset(
          a.dx + (b.dx - a.dx) * segProgress,
          a.dy + (b.dy - a.dy) * segProgress,
        );
        canvas.drawLine(a, pt, pathPaint);
      }
    }

    // Draw nodes
    for (final city in _pos.keys) {
      if (!graph.adjList.containsKey(city)) continue;
      final pt = _p(city, size);
      final isS = city == start;
      final isE = city == end;
      final isVia = result.path.contains(city) && !isS && !isE;

      final fillColor = isS
          ? const Color(0xFF1A73E8)
          : isE
              ? Colors.green
              : isVia
                  ? Colors.orange
                  : Colors.white;

      final strokeColor = isS || isE || isVia
          ? fillColor
          : Colors.blueGrey.shade300;

      final radius = isS || isE ? 13.0 : isVia ? 10.0 : 7.0;

      // Shadow
      canvas.drawCircle(
        pt + const Offset(0, 1.5),
        radius,
        Paint()..color = Colors.black12,
      );
      // Fill
      canvas.drawCircle(pt, radius, Paint()..color = fillColor);
      // Stroke
      canvas.drawCircle(
        pt,
        radius,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // City name
      _drawText(
        canvas,
        city,
        pt - Offset(0, radius + 9),
        fontSize: city.length > 8 ? 8.5 : 9.5,
        color: const Color(0xFF1B2A4A),
        bold: isS || isE,
      );

      // Show all distances
      if (showAllDist) {
        final d = result.allDistances[city];
        if (d != null && d < 999999) {
          _drawText(
            canvas,
            '${d}km',
            pt + Offset(0, radius + 10),
            fontSize: 8.5,
            color: Colors.purple.shade400,
          );
        }
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    double fontSize = 10,
    Color color = Colors.black,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.progress != progress ||
      old.showWeights != showWeights ||
      old.showAllDist != showAllDist;
}