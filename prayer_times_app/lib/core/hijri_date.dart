class HijriDate {
  const HijriDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static const months = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  String get monthName => months[month - 1];

  String get label => '$day $monthName $year هـ';

  /// التقويم المستخدم في التطبيق المرجعي (فرق يوم عن الخوارزمية الكويتية الشائعة).
  factory HijriDate.fromGregorian(DateTime date) {
    var y = date.year;
    var m = date.month;
    var d = date.day;
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    final a = y ~/ 100;
    final b = 2 - a + a ~/ 4;
    final jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524;
    var l = jd - 1948439 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDate(year, month, day);
  }
}

const gregorianMonths = [
  'كانون الثاني',
  'شباط',
  'آذار',
  'نيسان',
  'أيار',
  'حزيران',
  'تموز',
  'آب',
  'أيلول',
  'تشرين الأول',
  'تشرين الثاني',
  'كانون الأول',
];

const arabicWeekdays = [
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

String formatGregorian(DateTime date) {
  final weekday = arabicWeekdays[date.weekday - 1];
  return '$weekday · ${date.day} ${gregorianMonths[date.month - 1]} ${date.year}';
}
