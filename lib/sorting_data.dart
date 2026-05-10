import 'dart:math';

/// نموذج الطالب
class Student {
  final String name;
  final int grade;
  const Student(this.name, this.grade);

  @override
  String toString() => '$name ($grade)';
}

/// نتيجة عملية الترتيب
class SortResult {
  final List<Student> original;
  final List<Student> sorted;
  final int comparisons;
  final int swaps;
  final int executionMicroseconds;
  final String algorithmName;

  const SortResult({
    required this.original,
    required this.sorted,
    required this.comparisons,
    required this.swaps,
    required this.executionMicroseconds,
    required this.algorithmName,
  });
}

/// هيكل البيانات: قائمة طلاب قابلة للترتيب
/// نستخدم List (مصفوفة ديناميكية) وليس Linked List
/// السبب: الوصول العشوائي O(1) مطلوب لعمليات الترتيب (swap, compare)
class StudentList {
  final List<Student> data;

  StudentList(this.data);

  /// أسماء عشوائية لتوليد بيانات تجريبية
  static const _firstNames = [
    'Ahmed', 'Mohamed', 'Ali', 'Omar', 'Hassan', 'Youssef', 'Khalid', 'Ibrahim',
    'Sara', 'Fatma', 'Nour', 'Mona', 'Hana', 'Layla', 'Amira', 'Dina',
    'Tarek', 'Karim', 'Mahmoud', 'Mostafa', 'Rania', 'Salma', 'Yasmin', 'Mariam',
  ];

  static const _lastNames = [
    'Hassan', 'Ali', 'Mohamed', 'Ibrahim', 'Khalil', 'Salem', 'Nasser', 'Farouk',
    'Mansour', 'Saeed', 'Abdallah', 'Sayed', 'Othman', 'Sharif', 'Tamer', 'Gamal',
  ];

  /// إنشاء قائمة طلاب عشوائية
  factory StudentList.random(int size) {
    final rng = Random();
    return StudentList(List.generate(size, (i) {
      final first = _firstNames[rng.nextInt(_firstNames.length)];
      final last = _lastNames[rng.nextInt(_lastNames.length)];
      final grade = rng.nextInt(100) + 1; // درجة من 1 لـ 100
      return Student('$first $last', grade);
    }));
  }

  /// نسخة من القائمة
  List<Student> copy() => List<Student>.from(data);

  /// عدد الطلاب
  int get length => data.length;

  /// إضافة طالب
  void add(Student s) => data.add(s);

  /// حذف طالب بالموقع
  void removeAt(int index) => data.removeAt(index);

  /// مسح الكل
  void clear() => data.clear();

  /// هل القائمة مرتبة حسب الدرجة؟
  bool get isSorted {
    for (int i = 0; i < data.length - 1; i++) {
      if (data[i].grade > data[i + 1].grade) return false;
    }
    return true;
  }
}
