import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'algorithm_benchmark.dart';
import 'app_locale.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});
  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  List<BenchmarkEntry>? _results;
  bool _running = false;

  Future<void> _runBenchmark() async {
    setState(() => _running = true);
    await Future.delayed(const Duration(milliseconds: 100));
    final r = AlgorithmBenchmark.runScalabilityTest(sizes: const [10, 25, 50, 100, 200, 400], runsPerSize: 3);
    if (mounted) setState(() { _results = r; _running = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('Performance Benchmark'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              const Icon(Icons.analytics, color: Colors.white, size: 36), const SizedBox(height: 8),
              Text(L.t('Scalability Test'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(L.t('Run both algorithms on random graphs of increasing size\nto empirically verify theoretical complexity.'),
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
            ])),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _running ? null : _runBenchmark,
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: _running ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
            label: Text(L.t(_running ? 'Running Benchmark...' : 'Run Benchmark'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 20),
          if (_results != null) ...[
            _chartCard(L.t('Execution Time (µs)'), cs, _buildTimeChart(cs)), const SizedBox(height: 16),
            _chartCard(L.t('Edge Relaxations'), cs, _buildRelaxChart(cs)), const SizedBox(height: 16),
            _dataTable(cs), const SizedBox(height: 16),
            _analysisCard(cs),
          ],
          const SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget _chartCard(String title, ColorScheme cs, Widget chart) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
      const SizedBox(height: 4), _legend(cs), const SizedBox(height: 12),
      SizedBox(height: 220, child: chart),
    ]));

  Widget _legend(ColorScheme cs) => Row(children: [
    Container(width: 14, height: 14, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4), Text('Dijkstra', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    const SizedBox(width: 14),
    Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4), Text('Bellman-Ford', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
  ]);

  Widget _buildTimeChart(ColorScheme cs) {
    final r = _results!;
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: r.map((e) => e.bellmanTimeMicro > e.dijkstraTimeMicro ? e.bellmanTimeMicro : e.dijkstraTimeMicro).reduce((a, b) => a > b ? a : b) * 1.2,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt(); if (i < 0 || i >= r.length) return const SizedBox();
          return Text('V=${r[i].nodeCount}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant));
        })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: cs.outlineVariant.withOpacity(0.3), strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(r.length, (i) => BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: r[i].dijkstraTimeMicro.toDouble(), color: cs.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        BarChartRodData(toY: r[i].bellmanTimeMicro.toDouble(), color: Colors.orange, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ])),
    ));
  }

  Widget _buildRelaxChart(ColorScheme cs) {
    final r = _results!;
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(spots: List.generate(r.length, (i) => FlSpot(i.toDouble(), r[i].dijkstraRelaxations.toDouble())),
            color: cs.primary, barWidth: 3, isCurved: true, dotData: const FlDotData(show: true)),
        LineChartBarData(spots: List.generate(r.length, (i) => FlSpot(i.toDouble(), r[i].bellmanRelaxations.toDouble())),
            color: Colors.orange, barWidth: 3, isCurved: true, dotData: const FlDotData(show: true)),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 55, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt(); if (i < 0 || i >= r.length) return const SizedBox();
          return Text('V=${r[i].nodeCount}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant));
        })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(getDrawingHorizontalLine: (v) => FlLine(color: cs.outlineVariant.withOpacity(0.3), strokeWidth: 1)),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _dataTable(ColorScheme cs) {
    Widget row(String v, String e, String dt, String bt, String dr, String br, {bool h = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      decoration: BoxDecoration(color: h ? cs.primaryContainer.withOpacity(0.5) : null,
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3)))),
      child: Row(children: [
        Expanded(child: Text(v, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: h ? FontWeight.bold : FontWeight.normal))),
        Expanded(child: Text(e, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: h ? FontWeight.bold : FontWeight.normal))),
        Expanded(child: Text(dt, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: h ? null : cs.primary, fontWeight: h ? FontWeight.bold : FontWeight.normal))),
        Expanded(child: Text(bt, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: h ? null : Colors.orange, fontWeight: h ? FontWeight.bold : FontWeight.normal))),
        Expanded(child: Text(dr, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: h ? FontWeight.bold : FontWeight.normal))),
        Expanded(child: Text(br, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: h ? FontWeight.bold : FontWeight.normal))),
      ]));
    return Container(
      padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(L.t('Raw Data'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
        const SizedBox(height: 10),
        row('V', 'E', 'D(µs)', 'BF(µs)', 'D Relax', 'BF Relax', h: true),
        ...(_results!.map((r) => row('${r.nodeCount}', '${r.edgeCount}', '${r.dijkstraTimeMicro}', '${r.bellmanTimeMicro}', '${r.dijkstraRelaxations}', '${r.bellmanRelaxations}'))),
      ]));
  }

  Widget _analysisCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.lightbulb, color: Colors.amber, size: 20), const SizedBox(width: 8),
        Text(L.t('Analysis'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
      ]),
      const SizedBox(height: 10),
      Text(L.isArabic
          ? '• ديكسترا يعمل بتعقيد O(V²) — وقت التنفيذ ينمو تربيعياً مع V.\n'
            '• بلمان-فورد يعمل بتعقيد O(V·E) — أبطأ بكثير للرسوم الكثيفة.\n'
            '• الرسوم البيانية تؤكد التوقعات النظرية.\n'
            '• لشبكة المدن المصرية (V=14, E=16)، كلاهما سريع.\n'
            '• ديكسترا الأمثل للأوزان غير السالبة؛ بلمان-فورد ضروري فقط مع الحواف السالبة.'
          : '• Dijkstra runs in O(V²) — execution time grows quadratically with V.\n'
            '• Bellman-Ford runs in O(V·E) — significantly slower for dense graphs.\n'
            '• The charts confirm theoretical predictions.\n'
            '• For our Egyptian cities graph (V=14, E=16), both are fast.\n'
            '• Dijkstra is optimal for non-negative weights; Bellman-Ford is needed only when negative edges exist.',
          style: TextStyle(fontSize: 12.5, height: 1.7, color: cs.onSurfaceVariant)),
    ]));
}
