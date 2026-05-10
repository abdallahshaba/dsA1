import 'sorting_data.dart';

/// خوارزمية ترتيب الدمج (Merge Sort)
/// النهج: فرّق وامزج (Divide & Conquer)
/// الترتيب: حسب الدرجة (grade) تصاعدياً
/// التعقيد: O(n log n) في كل الحالات
class MergeSort {
  static int _comparisons = 0;

  static SortResult sort(List<Student> input) {
    final original = List<Student>.from(input);
    _comparisons = 0;
    final sw = Stopwatch()..start();

    final sorted = _mergeSort(List<Student>.from(input));

    sw.stop();
    return SortResult(
      original: original,
      sorted: sorted,
      comparisons: _comparisons,
      swaps: 0, // Merge Sort مش بيعمل swap — بيعمل merge
      executionMicroseconds: sw.elapsedMicroseconds,
      algorithmName: 'Merge Sort',
    );
  }

  /// التقسيم (Divide)
  static List<Student> _mergeSort(List<Student> arr) {
    if (arr.length <= 1) return arr;

    final mid = arr.length ~/ 2;
    final left = _mergeSort(arr.sublist(0, mid));
    final right = _mergeSort(arr.sublist(mid));

    return _merge(left, right);
  }

  /// الدمج (Merge) — ادمج قائمتين مرتبتين في قائمة واحدة مرتبة
  static List<Student> _merge(List<Student> left, List<Student> right) {
    final result = <Student>[];
    int i = 0, j = 0;

    while (i < left.length && j < right.length) {
      _comparisons++;
      if (left[i].grade <= right[j].grade) {
        result.add(left[i]);
        i++;
      } else {
        result.add(right[j]);
        j++;
      }
    }

    result.addAll(left.sublist(i));
    result.addAll(right.sublist(j));
    return result;
  }
}
