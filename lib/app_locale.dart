/// Lightweight localization: English is the key, Arabic is the value.
/// Usage: L.t('Smart Route Finder') → returns Arabic or English based on L.isArabic.
class L {
  static bool isArabic = false;

  /// Translate a key. English text IS the key.
  static String t(String key) => isArabic ? (_ar[key] ?? key) : key;

  /// Direction-aware text alignment
  static bool get isRtl => isArabic;

  static const Map<String, String> _ar = {
    // ─── App ───
    'Smart Route Finder': 'باحث المسارات الذكي',
    'Smart Route Finder Pro': 'باحث المسارات الذكي برو',
    'ELE253 – DSA Project': 'مشروع ELE253 – هياكل بيانات',
    'Toggle Dark Mode': 'تبديل الوضع الليلي',

    // ─── Home Page ───
    'Find the shortest route between Egyptian cities':
        'اعثر على أقصر مسار بين المدن المصرية',
    'Algorithm': 'الخوارزمية',
    'Compare': 'مقارنة',
    'Starting City': 'مدينة البداية',
    'Select starting city': 'اختر مدينة البداية',
    'Destination City': 'مدينة الوصول',
    'Select destination city': 'اختر مدينة الوصول',
    'Max Stops (optional)': 'أقصى عدد محطات (اختياري)',
    'No limit': 'بدون حد',
    'max stops': 'أقصى محطات',
    'Any': 'الكل',
    'Find Shortest Path': 'ابحث عن أقصر مسار',
    'Compare Algorithms': 'قارن الخوارزميات',
    'Cities': 'المدن',
    'Roads': 'الطرق',
    'Both': 'كلاهما',
    'How it works': 'كيف تعمل',
    'Time': 'الوقت',
    'Space': 'المساحة',
    'cities': 'مدن',
    'roads': 'طرق',
    'Please select both cities.': 'الرجاء اختيار المدينتين.',
    'Start and destination must be different.':
        'مدينة البداية والوصول يجب أن تكونا مختلفتين.',
    'Bellman-Ford relaxes all edges V-1 times using dynamic programming. It handles negative weights and detects negative cycles.':
        'بلمان-فورد يرخي كل الحواف V-1 مرة باستخدام البرمجة الديناميكية. يتعامل مع الأوزان السالبة ويكشف الدورات السالبة.',
    'Dijkstra\'s greedy algorithm explores nodes by increasing distance to guarantee the global shortest path for non-negative weights.':
        'خوارزمية ديكسترا الجشعة تستكشف العقد بترتيب المسافة المتزايدة لضمان أقصر مسار عام للأوزان غير السالبة.',

    // ─── Drawer ───
    'Home': 'الرئيسية',
    'Performance Benchmark': 'اختبار الأداء',
    'Complexity Analysis': 'تحليل التعقيد',
    'Graph Editor': 'محرر الشبكة',
    'Graph Info': 'معلومات الشبكة',
    'Search History': 'سجل البحث',
    'Algorithm Visualizer': 'عرض خطوات الخوارزمية',
    'Travel Cost Estimator': 'تقدير تكلفة الرحلة',
    'About': 'عن المشروع',
    'Language': 'اللغة',

    // ─── Result Page ───
    'Route Result': 'نتيجة المسار',
    'View on Map': 'عرض على الخريطة',
    'Shortest Distance': 'أقصر مسافة',
    'stop': 'محطة',
    'stops': 'محطات',
    'Performance Metrics': 'مقاييس الأداء',
    'Visited': 'تمت زيارتها',
    'Relaxed': 'تم ترخيها',
    'Route Details': 'تفاصيل المسار',
    'Starting point': 'نقطة البداية',
    'Destination': 'الوجهة',
    'Intermediate stop': 'محطة وسيطة',
    'All distances from start': 'جميع المسافات من البداية',
    'Search Again': 'ابحث مجدداً',
    'No Route Found': 'لم يتم العثور على مسار',
    'No road connection exists between': 'لا يوجد اتصال طريق بين',
    'and': 'و',
    'Negative cycle detected in graph!': 'تم اكتشاف دورة سالبة في الشبكة!',
    'Go Back': 'رجوع',
    'From': 'من',
    'To': 'إلى',
    'saved': 'وفّر',
    'km vs direct road': 'كم مقارنة بالطريق المباشر',
    'Direct road': 'الطريق المباشر',
    'This route': 'هذا المسار',

    // ─── Comparison Page ───
    'Algorithm Comparison': 'مقارنة الخوارزميات',
    'Dijkstra vs Bellman-Ford': 'ديكسترا ضد بلمان-فورد',
    'Distance': 'المسافة',
    'Relaxations': 'عمليات الترخية',
    'Detailed Comparison': 'مقارنة تفصيلية',
    'Metric': 'المقياس',
    'Exec Time': 'وقت التنفيذ',
    'Neg. Cycles': 'الدورات السالبة',
    'Complexity': 'التعقيد',
    'N/A': 'غ/م',
    'Detected!': 'تم اكتشافها!',
    'None': 'لا يوجد',
    'Path Comparison': 'مقارنة المسارات',
    'No path': 'لا يوجد مسار',
    'Both algorithms found the same optimal path!':
        'كلا الخوارزميتين وجدتا نفس المسار الأمثل!',
    'Different paths found (both may be optimal if same distance).':
        'تم العثور على مسارات مختلفة (كلاهما قد يكون أمثل إذا كانت المسافة متساوية).',
    'Wins!': 'الفائز!',
    'Dijkstra\'s greedy approach is more efficient for non-negative weights.':
        'نهج ديكسترا الجشع أكثر كفاءة للأوزان غير السالبة.',
    'Bellman-Ford performed better due to early termination.':
        'بلمان-فورد كان أفضل بسبب الإنهاء المبكر.',

    // ─── Benchmark Page ───
    'Scalability Test': 'اختبار قابلية التوسع',
    'Run both algorithms on random graphs of increasing size\nto empirically verify theoretical complexity.':
        'تشغيل كلا الخوارزميتين على رسوم بيانية عشوائية بأحجام متزايدة\nللتحقق عملياً من التعقيد النظري.',
    'Running Benchmark...': 'جاري اختبار الأداء...',
    'Run Benchmark': 'تشغيل الاختبار',
    'Execution Time (µs)': 'وقت التنفيذ (µs)',
    'Edge Relaxations': 'عمليات ترخية الحواف',
    'Raw Data': 'البيانات الخام',
    'Analysis': 'التحليل',

    // ─── Complexity Page ───
    'Dijkstra\'s Algorithm': 'خوارزمية ديكسترا',
    'Description': 'الوصف',
    'Pseudocode': 'الكود الوهمي',
    'A greedy algorithm that finds the shortest path from a single source to all other vertices in a weighted graph with non-negative edge weights. It works by always selecting the unvisited vertex with the smallest known distance and relaxing its neighbors.':
        'خوارزمية جشعة تجد أقصر مسار من مصدر واحد إلى جميع الرؤوس الأخرى في رسم بياني موزون بأوزان حواف غير سالبة. تعمل عن طريق اختيار الرأس غير المزار ذو أصغر مسافة معروفة وترخية جيرانه.',
    'Bellman-Ford Algorithm': 'خوارزمية بلمان-فورد',
    'A dynamic programming algorithm that computes shortest paths from a single source vertex to all other vertices. Unlike Dijkstra, it can handle negative edge weights and detect negative cycles. It relaxes all edges V-1 times.':
        'خوارزمية برمجة ديناميكية تحسب أقصر المسارات من رأس مصدر واحد إلى جميع الرؤوس الأخرى. على عكس ديكسترا، يمكنها التعامل مع أوزان الحواف السالبة واكتشاف الدورات السالبة. ترخي جميع الحواف V-1 مرة.',
    'Head-to-Head Comparison': 'مقارنة مباشرة',
    'When to Use Which?': 'متى تستخدم أيهما؟',
    'Use Dijkstra when all edge weights are non-negative — it\'s faster.':
        'استخدم ديكسترا عندما تكون جميع أوزان الحواف غير سالبة — إنها أسرع.',
    'Use Bellman-Ford when the graph may have negative weights.':
        'استخدم بلمان-فورد عندما قد يحتوي الرسم البياني على أوزان سالبة.',
    'Bellman-Ford can detect negative cycles; Dijkstra cannot.':
        'بلمان-فورد يمكنه اكتشاف الدورات السالبة؛ ديكسترا لا يمكنه.',
    'For sparse graphs, Dijkstra with a min-heap is O((V+E) log V).':
        'للرسوم البيانية المتناثرة، ديكسترا مع كومة صغرى هي O((V+E) log V).',
    'Data Structure: Adjacency List': 'هيكل البيانات: قائمة التجاور',
    'Why Adjacency List over Matrix?': 'لماذا قائمة التجاور وليس المصفوفة؟',
    'Our graph is sparse (E=16 << V²=196) — list saves memory.':
        'الرسم البياني متناثر (E=16 << V²=196) — القائمة توفر الذاكرة.',
    'Adjacency List: O(V+E) space vs Matrix: O(V²) space.':
        'قائمة التجاور: O(V+E) مساحة مقابل المصفوفة: O(V²) مساحة.',
    'Iterating neighbors is O(degree) vs O(V) for matrix.':
        'التكرار على الجيران O(degree) مقابل O(V) للمصفوفة.',
    'Adding/removing edges is O(1) for both.':
        'إضافة/حذف الحواف O(1) لكليهما.',
    'Feature': 'الميزة',
    'Neg. Weights': 'أوزان سالبة',
    'Neg. Cycles Detection': 'اكتشاف دورات سالبة',
    'Detect': 'اكتشاف',
    'Approach': 'النهج',
    'Greedy': 'جشع',
    'Dynamic Prog.': 'برمجة ديناميكية',
    'Faster?': 'أسرع؟',
    'Usually': 'عادةً',
    'Slower': 'أبطأ',
    'Case': 'الحالة',
    'Best': 'أفضل',
    'Average': 'متوسط',
    'Worst': 'أسوأ',

    // ─── Graph Editor ───
    'Reset': 'إعادة تعيين',
    'Add City': 'إضافة مدينة',
    'City name': 'اسم المدينة',
    'Add': 'إضافة',
    'Add Road': 'إضافة طريق',
    'Distance (km)': 'المسافة (كم)',
    'Density': 'الكثافة',
    'Enter a city name': 'أدخل اسم المدينة',
    'City already exists': 'المدينة موجودة بالفعل',
    'Added': 'تمت الإضافة',
    'Select both cities': 'اختر كلا المدينتين',
    'Must be different cities': 'يجب أن تكونا مدينتين مختلفتين',
    'Enter a valid positive weight': 'أدخل وزناً موجباً صحيحاً',
    'Road added': 'تمت إضافة الطريق',
    'Graph reset to default': 'تم إعادة تعيين الشبكة',

    // ─── History Page ───
    'History': 'السجل',
    'No search history yet': 'لا يوجد سجل بحث بعد',
    'via': 'عبر',

    // ─── Map Page ───
    'Route Map': 'خريطة المسار',
    'Show Weights': 'إظهار الأوزان',
    'Show All Distances': 'إظهار جميع المسافات',

    // ─── Graph Info Page ───
    'Connected': 'متصلة',
    'Yes': 'نعم',
    'No': 'لا',
    'Total': 'الإجمالي',
    'Heaviest Roads': 'أثقل الطرق',
    'Node Degrees': 'درجات العقد',
    'connections': 'اتصالات',

    // ─── Splash Screen ───
    'Powered by Flutter & Dart': 'مدعوم بـ Flutter و Dart',

    // ─── About Page ───
    'About Project': 'عن المشروع',
    'Project Name': 'اسم المشروع',
    'Course': 'المادة',
    'Data Structures and Algorithms': 'هياكل البيانات والخوارزميات',
    'Technology': 'التقنية',
    'Libraries': 'المكتبات',
    'Version': 'الإصدار',
    'Algorithms Used': 'الخوارزميات المستخدمة',
    'Data Structures Used': 'هياكل البيانات المستخدمة',
    'Adjacency List (Map<String, Map<String, int>>)':
        'قائمة تجاور (Map<String, Map<String, int>>)',
    'Priority Queue (simulated)': 'طابور أولويات (محاكاة)',
    'Hash Map for distances': 'خريطة تجزئة للمسافات',

    // ─── Algorithm Visualizer ───
    'Select Start City': 'اختر مدينة البداية',
    'Select End City': 'اختر مدينة الوصول',
    'Select Algorithm': 'اختر الخوارزمية',
    'Visualize': 'عرض التنفيذ',
    'Step': 'خطوة',
    'of': 'من',
    'Initialize': 'تهيئة',
    'Set all distances to ∞, source to 0': 'تعيين جميع المسافات إلى ∞، المصدر إلى 0',
    'Visit Node': 'زيارة عقدة',
    'Select unvisited node with minimum distance':
        'اختيار العقدة غير المزارة ذات أقل مسافة',
    'Relax Edge': 'ترخية حافة',
    'Update distance if shorter path found': 'تحديث المسافة إذا وُجد مسار أقصر',
    'Done': 'انتهى',
    'Algorithm completed!': 'اكتملت الخوارزمية!',
    'Path Found': 'تم العثور على مسار',
    'No Path': 'لا يوجد مسار',
    'Current Distances': 'المسافات الحالية',
    'Prev': 'السابق',
    'Next': 'التالي',
    'Play': 'تشغيل',
    'Pause': 'إيقاف',
    'Speed': 'السرعة',
    'Please select start and end cities': 'الرجاء اختيار مدينتي البداية والنهاية',

    // ─── Route Cost Page ───
    'Route Cost Estimator': 'تقدير تكلفة المسار',
    'Fuel Consumption': 'استهلاك الوقود',
    'L/100km': 'لتر/100كم',
    'Fuel Price': 'سعر الوقود',
    'EGP/L': 'جنيه/لتر',
    'Average Speed': 'السرعة المتوسطة',
    'km/h': 'كم/س',
    'Calculate': 'احسب',
    'Estimated Fuel Cost': 'تكلفة الوقود المقدرة',
    'Estimated Travel Time': 'وقت السفر المقدر',
    'Fuel Needed': 'الوقود المطلوب',
    'hours': 'ساعات',
    'minutes': 'دقائق',
    'liters': 'لتر',
    'EGP': 'جنيه',
    'Route Summary': 'ملخص المسار',
    'Please find a route first from the home page':
        'الرجاء البحث عن مسار أولاً من الصفحة الرئيسية',
  };
}
