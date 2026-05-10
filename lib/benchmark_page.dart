import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sorting_data.dart';
import 'bubble_sort.dart';
import 'merge_sort.dart';

class BenchmarkEntry {
  final int size;
  final int bubbleTimeMicro;
  final int mergeTimeMicro;
  final int bubbleComparisons;
  final int mergeComparisons;
  const BenchmarkEntry({required this.size, required this.bubbleTimeMicro, required this.mergeTimeMicro,
      required this.bubbleComparisons, required this.mergeComparisons});
}

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

    final sizes = [50, 100, 250, 500, 1000, 2000];
    final results = <BenchmarkEntry>[];

    for (final n in sizes) {
      int totalBT = 0, totalMT = 0, totalBC = 0, totalMC = 0;
      const runs = 3;
      for (int r = 0; r < runs; r++) {
        final data = StudentList.random(n).data;
        final b = BubbleSort.sort(data);
        final m = MergeSort.sort(data);
        totalBT += b.executionMicroseconds;
        totalMT += m.executionMicroseconds;
        totalBC += b.comparisons;
        totalMC += m.comparisons;
      }
      results.add(BenchmarkEntry(
        size: n,
        bubbleTimeMicro: totalBT ~/ runs,
        mergeTimeMicro: totalMT ~/ runs,
        bubbleComparisons: totalBC ~/ runs,
        mergeComparisons: totalMC ~/ runs,
      ));
    }

    if (mounted) setState(() { _results = results; _running = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Benchmark')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                borderRadius: BorderRadius.circular(16)),
            child: const Column(children: [
              Icon(Icons.analytics, color: Colors.white, size: 36), SizedBox(height: 8),
              Text('Scalability Test', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Sort random student lists of increasing size\nto empirically verify theoretical complexity.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
            ])),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _running ? null : _runBenchmark,
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: _running
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow),
            label: Text(_running ? 'Running...' : 'Run Benchmark',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 20),
          if (_results != null) ...[
            _chartCard('Execution Time (µs)', cs, _buildTimeChart(cs)),
            const SizedBox(height: 16),
            _chartCard('Comparisons Count', cs, _buildCompChart(cs)),
            const SizedBox(height: 16),
            _dataTable(cs),
            const SizedBox(height: 16),
            _analysisCard(cs),
          ],
          const SizedBox(height: 20),
        ])),
    );
  }

  Widget _chartCard(String title, ColorScheme cs, Widget chart) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
      const SizedBox(height: 4), _legend(cs), const SizedBox(height: 12),
      SizedBox(height: 220, child: chart),
    ]));

  Widget _legend(ColorScheme cs) => Row(children: [
    Container(width: 14, height: 14, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4), Text('Bubble Sort', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    const SizedBox(width: 14),
    Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4), Text('Merge Sort', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
  ]);

  Widget _buildTimeChart(ColorScheme cs) {
    final r = _results!;
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: r.map((e) => e.bubbleTimeMicro > e.mergeTimeMicro ? e.bubbleTimeMicro : e.mergeTimeMicro)
          .reduce((a, b) => a > b ? a : b) * 1.2,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 55,
            getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt(); if (i < 0 || i >= r.length) return const SizedBox();
              return Text('n=${r[i].size}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant));
            })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(color: cs.outlineVariant.withValues(alpha: 0.3), strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(r.length, (i) => BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: r[i].bubbleTimeMicro.toDouble(), color: cs.primary, width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        BarChartRodData(toY: r[i].mergeTimeMicro.toDouble(), color: Colors.orange, width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ])),
    ));
  }

  Widget _buildCompChart(ColorScheme cs) {
    final r = _results!;
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(spots: List.generate(r.length, (i) => FlSpot(i.toDouble(), r[i].bubbleComparisons.toDouble())),
            color: cs.primary, barWidth: 3, isCurved: true, dotData: const FlDotData(show: true)),
        LineChartBarData(spots: List.generate(r.length, (i) => FlSpot(i.toDouble(), r[i].mergeComparisons.toDouble())),
            color: Colors.orange, barWidth: 3, isCurved: true, dotData: const FlDotData(show: true)),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60,
            getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt(); if (i < 0 || i >= r.length) return const SizedBox();
              return Text('n=${r[i].size}', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant));
            })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(getDrawingHorizontalLine: (v) => FlLine(color: cs.outlineVariant.withValues(alpha: 0.3), strokeWidth: 1)),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _dataTable(ColorScheme cs) {
    Widget row(String n, String bt, String mt, String bc, String mc, {bool h = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      decoration: BoxDecoration(color: h ? cs.primaryContainer.withValues(alpha: 0.5) : null,
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)))),
      child: Row(children: [
        Expanded(child: Text(n, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: h ? FontWeight.bold : FontWeight.normal))),
        Expanded(child: Text(bt, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: h ? null : cs.primary))),
        Expanded(child: Text(mt, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: h ? null : Colors.orange))),
        Expanded(child: Text(bc, textAlign: TextAlign.center, style: TextStyle(fontSize: 10))),
        Expanded(child: Text(mc, textAlign: TextAlign.center, style: TextStyle(fontSize: 10))),
      ]));
    return Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Raw Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
        const SizedBox(height: 10),
        row('Students', 'Bubble(µs)', 'Merge(µs)', 'B.Comp', 'M.Comp', h: true),
        ...(_results!.map((r) => row('${r.size}', '${r.bubbleTimeMicro}', '${r.mergeTimeMicro}',
            '${r.bubbleComparisons}', '${r.mergeComparisons}'))),
      ]));
  }

  Widget _analysisCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.lightbulb, color: Colors.amber, size: 20), const SizedBox(width: 8),
        Text('Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
      ]),
      const SizedBox(height: 10),
      Text('• Bubble Sort runs in O(n²) — doubling students quadruples time.\n'
          '• Merge Sort runs in O(n log n) — much more scalable.\n'
          '• Charts confirm: Bubble Sort grows much faster than Merge Sort.\n'
          '• For 50 students, both are fast (difference is negligible).\n'
          '• For 2000 students, Merge Sort is dramatically faster.\n'
          '• Trade-off: Bubble Sort uses O(1) space; Merge Sort uses O(n).',
          style: TextStyle(fontSize: 12.5, height: 1.7, color: cs.onSurfaceVariant)),
    ]));
}
