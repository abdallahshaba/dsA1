import 'package:flutter/material.dart';
import 'sorting_data.dart';
import 'bubble_sort.dart';
import 'merge_sort.dart';
import 'result_page.dart';
import 'comparison_page.dart';
import 'benchmark_page.dart';
import 'complexity_page.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();
  final StudentList _students = StudentList([]);
  String _algo = 'Bubble Sort';
  bool _loading = false;

  void _addStudent() {
    final name = _nameCtrl.text.trim();
    final grade = int.tryParse(_gradeCtrl.text.trim());
    if (name.isEmpty) { _snack('Please enter student name'); return; }
    if (grade == null || grade < 0 || grade > 100) { _snack('Enter a valid grade (0-100)'); return; }
    setState(() {
      _students.add(Student(name, grade));
      _nameCtrl.clear();
      _gradeCtrl.clear();
    });
  }

  void _generateRandom() {
    setState(() {
      _students.data.clear();
      _students.data.addAll(StudentList.random(15).data);
    });
    _snack('Generated 15 random students');
  }

  void _clearList() => setState(() => _students.clear());

  void _sort() {
    if (_students.length < 2) { _snack('Add at least 2 students'); return; }

    if (_algo == 'Compare') {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => ComparisonPage(data: _students.copy())));
      return;
    }

    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      final result = _algo == 'Merge Sort'
          ? MergeSort.sort(_students.copy())
          : BubbleSort.sort(_students.copy());
      setState(() => _loading = false);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => ResultPage(result: result)));
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  void dispose() { _nameCtrl.dispose(); _gradeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Student Grade Sorter')),
      drawer: _buildDrawer(cs),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Icon(Icons.school, size: 56, color: cs.primary),
          const SizedBox(height: 8),
          Text('Sort students by their grades using different algorithms',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          // Stats
          Row(children: [
            _statCard('Students', '${_students.length}', Icons.people, Colors.blue, cs),
            const SizedBox(width: 8),
            _statCard('Sorted?', _students.length < 2 ? '—' : _students.isSorted ? 'Yes' : 'No',
                Icons.check_circle, _students.isSorted ? Colors.green : Colors.orange, cs),
            const SizedBox(width: 8),
            _statCard('Algorithm', _algo.split(' ')[0], Icons.memory, Colors.purple, cs),
          ]),
          const SizedBox(height: 20),
          // Algorithm selector
          Text('Algorithm', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 6),
          _algoSelector(cs),
          const SizedBox(height: 16),
          // Add student
          Text('Add Student', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(flex: 3, child: TextField(controller: _nameCtrl,
                decoration: InputDecoration(hintText: 'Student name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true))),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: TextField(controller: _gradeCtrl, keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Grade (0-100)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true),
                onSubmitted: (_) => _addStudent())),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addStudent,
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Add')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _generateRandom,
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('Random 15'),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: _clearList,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear All'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
          ]),
          const SizedBox(height: 16),
          // Current students
          if (_students.length > 0) ...[
            Text('Students (${_students.length})',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant)),
              child: Wrap(spacing: 6, runSpacing: 6,
                  children: List.generate(_students.length, (i) {
                    final s = _students.data[i];
                    return Chip(
                      avatar: CircleAvatar(backgroundColor: _gradeColor(s.grade),
                          child: Text('${s.grade}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
                      label: Text(s.name, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _students.removeAt(i)),
                      visualDensity: VisualDensity.compact,
                    );
                  })),
            ),
          ],
          const SizedBox(height: 20),
          // Sort button
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _sort,
                  style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: Icon(_algo == 'Compare' ? Icons.compare_arrows : Icons.sort, size: 22),
                  label: Text(_algo == 'Compare' ? 'Compare Algorithms' : 'Sort Students',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
          const SizedBox(height: 16),
          _infoCard(cs),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Color _gradeColor(int grade) {
    if (grade >= 85) return Colors.green;
    if (grade >= 70) return Colors.blue;
    if (grade >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDrawer(ColorScheme cs) => Drawer(
    child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary])),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(Icons.school, color: Colors.white, size: 40),
          SizedBox(height: 10),
          Text('Student Grade Sorter', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('ELE253 – DSA Project', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ),
      ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
      ListTile(leading: const Icon(Icons.analytics), title: const Text('Performance Benchmark'), onTap: () {
        Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const BenchmarkPage())); }),
      ListTile(leading: const Icon(Icons.school), title: const Text('Complexity Analysis'), onTap: () {
        Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplexityPage())); }),
      const Divider(),
      ListTile(leading: const Icon(Icons.info), title: const Text('About'), onTap: () {
        Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())); }),
    ]),
  );

  Widget _algoSelector(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      for (final a in ['Bubble Sort', 'Merge Sort', 'Compare'])
        Expanded(child: GestureDetector(
          onTap: () => setState(() => _algo = a),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: _algo == a ? cs.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
            child: Text(a, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: _algo == a ? cs.onPrimary : cs.onSurfaceVariant)),
          ),
        )),
    ]),
  );

  Widget _statCard(String label, String value, IconData icon, Color color, ColorScheme cs) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 20), const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
      ])),
  );

  Widget _infoCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.info_outline, size: 15, color: cs.primary), const SizedBox(width: 6),
        Text('How it works', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
      ]),
      const SizedBox(height: 6),
      Text(_algo == 'Merge Sort'
          ? 'Merge Sort divides the student list in half recursively, sorts each half by grade, then merges them. Always runs in O(n log n).'
          : 'Bubble Sort compares adjacent students by grade and swaps them if out of order. Repeats until sorted. Runs in O(n²).',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5)),
    ]),
  );
}