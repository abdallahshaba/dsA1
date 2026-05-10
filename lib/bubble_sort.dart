import 'sorting_data.dart';

/// خوارزمية ترتيب الفقاعة (Bubble Sort)
/// النهج: مقارنة كل عنصرين متجاورين وتبديلهم لو مش مرتبين
/// الترتيب: حسب الدرجة (grade) تصاعدياً
/// التعقيد: O(n²) في أسوأ ومتوسط الحالات
class BubbleSort {
  static SortResult sort(List<Student> input) {
    final arr = List<Student>.from(input);
    final original = List<Student>.from(input);
    final sw = Stopwatch()..start();
    int comparisons = 0;
    int swaps = 0;
    final n = arr.length;

    for (int i = 0; i < n - 1; i++) {
      bool swapped = false;
      for (int j = 0; j < n - i - 1; j++) {
        comparisons++;
        if (arr[j].grade > arr[j + 1].grade) {
          // تبديل
          final temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;
          swaps++;
          swapped = true;
        }
      }
      // تحسين: لو ملقيناش أي تبديل في اللفة = مرتب
      if (!swapped) break;
    }
    sw.stop();

    return SortResult(
      original: original,
      sorted: arr,
      comparisons: comparisons,
      swaps: swaps,
      executionMicroseconds: sw.elapsedMicroseconds,
      algorithmName: 'Bubble Sort',
    );
  }
}
