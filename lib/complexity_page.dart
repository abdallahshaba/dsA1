import 'package:flutter/material.dart';

class ComplexityPage extends StatelessWidget {
  const ComplexityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Complexity Analysis')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionCard(context, 'Bubble Sort', Icons.bubble_chart, cs.primary, [
            _subTitle('Description'),
            const Text('A simple comparison-based sorting algorithm. It repeatedly steps through the list, '
                'compares adjacent elements, and swaps them if they are in the wrong order. '
                'The pass through the list is repeated until the list is sorted.',
                style: TextStyle(height: 1.6, fontSize: 13)),
            const SizedBox(height: 16), _subTitle('Pseudocode'),
            _codeBlock(isDark,
              'BUBBLE-SORT(A, n):\n'
              '  for i = 0 to n-2:\n'
              '    swapped = false\n'
              '    for j = 0 to n-i-2:\n'
              '      if A[j] > A[j+1]:\n'
              '        swap(A[j], A[j+1])\n'
              '        swapped = true\n'
              '    if not swapped:\n'
              '      break    // Early termination'),
            const SizedBox(height: 16), _subTitle('Complexity'),
            _complexityTable(context, 'O(n)', 'O(n²)', 'O(n²)', 'O(1)'),
          ]),
          const SizedBox(height: 16),
          _sectionCard(context, 'Merge Sort', Icons.call_split, Colors.orange, [
            _subTitle('Description'),
            const Text('A divide-and-conquer algorithm that splits the list into halves, '
                'recursively sorts each half, and merges the sorted halves back together. '
                'It guarantees O(n log n) performance in all cases.',
                style: TextStyle(height: 1.6, fontSize: 13)),
            const SizedBox(height: 16), _subTitle('Pseudocode'),
            _codeBlock(isDark,
              'MERGE-SORT(A):\n'
              '  if length(A) <= 1:\n'
              '    return A\n'
              '  mid = length(A) / 2\n'
              '  left = MERGE-SORT(A[0..mid])\n'
              '  right = MERGE-SORT(A[mid..n])\n'
              '  return MERGE(left, right)\n'
              '\n'
              'MERGE(L, R):\n'
              '  result = []\n'
              '  while L and R not empty:\n'
              '    if L[0] <= R[0]:\n'
              '      result.add(L.removeFirst)\n'
              '    else:\n'
              '      result.add(R.removeFirst)\n'
              '  result.addAll(remaining)'),
            const SizedBox(height: 16), _subTitle('Complexity'),
            _complexityTable(context, 'O(n log n)', 'O(n log n)', 'O(n log n)', 'O(n)'),
          ]),
          const SizedBox(height: 16),
          _sectionCard(context, 'Head-to-Head Comparison', Icons.compare_arrows, Colors.purple, [
            _comparisonTable(context),
            const SizedBox(height: 16), _subTitle('When to Use Which?'),
            _bulletPoint('Use Bubble Sort for very small lists (n < 20) or educational purposes.'),
            _bulletPoint('Use Merge Sort for large datasets where performance matters.'),
            _bulletPoint('Bubble Sort is in-place (O(1) space); Merge Sort needs O(n) extra space.'),
            _bulletPoint('Both are stable — equal elements maintain their relative order.'),
            _bulletPoint('Merge Sort is preferred in practice for its guaranteed O(n log n).'),
          ]),
          const SizedBox(height: 16),
          _sectionCard(context, 'Data Structure: Array (List)', Icons.view_list, Colors.teal, [
            const Text('We use a dynamic array (Dart List<int>) to store the data. '
                'Arrays provide O(1) random access by index, which is essential for '
                'comparison and swap operations in sorting algorithms.',
                style: TextStyle(height: 1.6, fontSize: 13)),
            const SizedBox(height: 12), _subTitle('Why Array over Linked List?'),
            _bulletPoint('Arrays have O(1) random access; Linked Lists have O(n).'),
            _bulletPoint('Sorting needs frequent index-based access (arr[j], arr[j+1]).'),
            _bulletPoint('Arrays have better cache locality — faster in practice.'),
            _bulletPoint('Swap operation is O(1) for arrays using index.'),
            _bulletPoint('Linked Lists are better for frequent insertions/deletions, not sorting.'),
          ]),
          const SizedBox(height: 24),
        ])),
    );
  }

  Widget _sectionCard(BuildContext context, String title, IconData icon, Color accent, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: accent, size: 22), const SizedBox(width: 10),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: cs.onSurface)))]),
        const SizedBox(height: 14), ...children,
      ]));
  }

  Widget _subTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)));

  Widget _codeBlock(bool isDark, String code) => Container(width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10)),
    child: Text(code, style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.5,
        color: isDark ? const Color(0xFFCDD6F4) : Colors.black87)));

  Widget _bulletPoint(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5))),
    ]));

  Widget _complexityTable(BuildContext ctx, String best, String avg, String worst, String space) {
    final cs = Theme.of(ctx).colorScheme;
    return Table(border: TableBorder.all(color: cs.outlineVariant, borderRadius: BorderRadius.circular(8)), children: [
      _tableRow(ctx, ['Case', 'Time', 'Space'], header: true),
      _tableRow(ctx, ['Best', best, space]),
      _tableRow(ctx, ['Average', avg, space]),
      _tableRow(ctx, ['Worst', worst, space]),
    ]);
  }

  Widget _comparisonTable(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return Table(border: TableBorder.all(color: cs.outlineVariant, borderRadius: BorderRadius.circular(8)), children: [
      _tableRow(ctx, ['Feature', 'Bubble', 'Merge'], header: true),
      _tableRow(ctx, ['Best Time', 'O(n)', 'O(n log n)']),
      _tableRow(ctx, ['Worst Time', 'O(n²)', 'O(n log n)']),
      _tableRow(ctx, ['Space', 'O(1)', 'O(n)']),
      _tableRow(ctx, ['Stable?', 'Yes', 'Yes']),
      _tableRow(ctx, ['Approach', 'Iterative', 'Divide & Conquer']),
      _tableRow(ctx, ['In-place?', 'Yes', 'No']),
      _tableRow(ctx, ['Adaptive?', 'Yes', 'No']),
    ]);
  }

  TableRow _tableRow(BuildContext ctx, List<String> cells, {bool header = false}) {
    final cs = Theme.of(ctx).colorScheme;
    return TableRow(decoration: header ? BoxDecoration(color: cs.primaryContainer) : null,
      children: cells.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(c, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: header ? FontWeight.bold : FontWeight.normal,
                color: header ? cs.onPrimaryContainer : cs.onSurface)))).toList());
  }
}
