import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerMethodOption {
  const PrayerMethodOption({
    required this.id,
    required this.nameAr,
    required this.method,
    this.description,
  });

  final String id;
  final String nameAr;
  final CalculationMethod method;
  final String? description;

  CalculationParameters parameters() => method.getParameters();
}

const syrianAwqafDescription =
    'الفجر 19.5° والعشاء 17.5° تحت الأفق، وفق التقويم المعتمد في سوريا. تُحسب المواقيت لإحداثيات موقعك الفعلية.';

const List<PrayerMethodOption> prayerMethodOptions = [
  PrayerMethodOption(
    id: 'syrian_awqaf',
    nameAr: 'وزارة الأوقاف السورية',
    method: CalculationMethod.egyptian,
    description: syrianAwqafDescription,
  ),
  PrayerMethodOption(
    id: 'muslim_world_league',
    nameAr: 'رابطة العالم الإسلامي',
    method: CalculationMethod.muslim_world_league,
  ),
  PrayerMethodOption(
    id: 'egyptian',
    nameAr: 'الهيئة المصرية',
    method: CalculationMethod.egyptian,
  ),
  PrayerMethodOption(
    id: 'umm_al_qura',
    nameAr: 'أم القرى',
    method: CalculationMethod.umm_al_qura,
  ),
  PrayerMethodOption(
    id: 'karachi',
    nameAr: 'جامعة العلوم كراتشي',
    method: CalculationMethod.karachi,
  ),
  PrayerMethodOption(
    id: 'dubai',
    nameAr: 'دبي',
    method: CalculationMethod.dubai,
  ),
  PrayerMethodOption(
    id: 'qatar',
    nameAr: 'قطر',
    method: CalculationMethod.qatar,
  ),
  PrayerMethodOption(
    id: 'kuwait',
    nameAr: 'الكويت',
    method: CalculationMethod.kuwait,
  ),
  PrayerMethodOption(
    id: 'singapore',
    nameAr: 'سنغافورة',
    method: CalculationMethod.singapore,
  ),
  PrayerMethodOption(
    id: 'north_america',
    nameAr: 'أمريكا الشمالية',
    method: CalculationMethod.north_america,
  ),
  PrayerMethodOption(
    id: 'turkey',
    nameAr: 'تركيا',
    method: CalculationMethod.turkey,
  ),
  PrayerMethodOption(
    id: 'tehran',
    nameAr: 'طهران',
    method: CalculationMethod.tehran,
  ),
];

PrayerMethodOption prayerMethodById(String? id) {
  for (final option in prayerMethodOptions) {
    if (option.id == id || option.method.name == id) return option;
  }
  return prayerMethodOptions.first;
}

String madhabName(Madhab m) {
  switch (m) {
    case Madhab.shafi:
      return 'الشافعي (الجمهور)';
    case Madhab.hanafi:
      return 'الحنفي';
  }
}

String methodName(CalculationMethod m) {
  for (final option in prayerMethodOptions) {
    if (option.method == m && option.id != 'syrian_awqaf') return option.nameAr;
  }
  return m.name;
}

class MinuteOffsets {
  const MinuteOffsets({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  int forName(String name) {
    switch (name) {
      case 'الفجر':
        return fajr;
      case 'الشروق':
        return sunrise;
      case 'الظهر':
        return dhuhr;
      case 'العصر':
        return asr;
      case 'المغرب':
        return maghrib;
      case 'العشاء':
        return isha;
      default:
        return 0;
    }
  }

  MinuteOffsets copyWithName(String name, int value) {
    return MinuteOffsets(
      fajr: name == 'الفجر' ? value : fajr,
      sunrise: name == 'الشروق' ? value : sunrise,
      dhuhr: name == 'الظهر' ? value : dhuhr,
      asr: name == 'العصر' ? value : asr,
      maghrib: name == 'المغرب' ? value : maghrib,
      isha: name == 'العشاء' ? value : isha,
    );
  }
}

class PrayerTimeEntry {
  const PrayerTimeEntry({required this.nameAr, required this.dateTime, required this.iconName});

  final String nameAr;
  final DateTime dateTime;
  final String iconName;

  bool get isSalah => nameAr != 'الشروق';
}

class NextPrayerInfo {
  const NextPrayerInfo({required this.next, required this.current, required this.remaining});

  final PrayerTimeEntry next;
  final PrayerTimeEntry? current;
  final Duration remaining;
}

class PrayerTimesService {
  Future<Position> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('خدمة الموقع معطلة. يرجى تفعيلها أو اختيار المدينة يدوياً.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض إذن الموقع. يمكنك اختيار المدينة يدوياً من الإعدادات.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('تم رفض إذن الموقع. يمكنك اختيار المدينة يدوياً من الإعدادات.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  List<PrayerTimeEntry> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    String methodId = 'syrian_awqaf',
    Madhab madhab = Madhab.shafi,
    MinuteOffsets offsets = const MinuteOffsets(),
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = prayerMethodById(methodId).parameters();
    params.madhab = madhab;
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents(date.year, date.month, date.day),
      params,
    );
    DateTime shift(DateTime time, int minutes) => time.add(Duration(minutes: minutes));
    return [
      PrayerTimeEntry(nameAr: 'الفجر', dateTime: shift(prayerTimes.fajr, offsets.fajr), iconName: 'fajr'),
      PrayerTimeEntry(nameAr: 'الشروق', dateTime: shift(prayerTimes.sunrise, offsets.sunrise), iconName: 'sunrise'),
      PrayerTimeEntry(nameAr: 'الظهر', dateTime: shift(prayerTimes.dhuhr, offsets.dhuhr), iconName: 'dhuhr'),
      PrayerTimeEntry(nameAr: 'العصر', dateTime: shift(prayerTimes.asr, offsets.asr), iconName: 'asr'),
      PrayerTimeEntry(nameAr: 'المغرب', dateTime: shift(prayerTimes.maghrib, offsets.maghrib), iconName: 'maghrib'),
      PrayerTimeEntry(nameAr: 'العشاء', dateTime: shift(prayerTimes.isha, offsets.isha), iconName: 'isha'),
    ];
  }

  List<PrayerTimeEntry> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
    CalculationMethod method = CalculationMethod.egyptian,
    Madhab madhab = Madhab.shafi,
  }) {
    return getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
      methodId: method.name,
      madhab: madhab,
    );
  }

  double getQiblaDirection(double latitude, double longitude) {
    return Qibla(Coordinates(latitude, longitude)).direction;
  }
}

String formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatTime12(DateTime dt) {
  final suffix = dt.hour < 12 ? 'ص' : 'م';
  var hour = dt.hour % 12;
  if (hour == 0) hour = 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute $suffix';
}

String formatCountdown(Duration duration) {
  final total = duration.isNegative ? Duration.zero : duration;
  final h = total.inHours.toString().padLeft(2, '0');
  final m = total.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = total.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String bearingName(double degrees) {
  const names = ['شمال', 'شمال شرق', 'شرق', 'جنوب شرق', 'جنوب', 'جنوب غرب', 'غرب', 'شمال غرب'];
  final index = ((degrees + 22.5) % 360) ~/ 45;
  return names[index];
}

NextPrayerInfo resolveNextPrayer({
  required List<PrayerTimeEntry> today,
  required List<PrayerTimeEntry> tomorrow,
  required DateTime now,
}) {
  PrayerTimeEntry? current;
  for (final entry in today) {
    if (!entry.isSalah) continue;
    if (!entry.dateTime.isAfter(now)) current = entry;
  }
  for (final entry in today) {
    if (!entry.isSalah) continue;
    if (entry.dateTime.isAfter(now)) {
      return NextPrayerInfo(next: entry, current: current, remaining: entry.dateTime.difference(now));
    }
  }
  final fajr = tomorrow.firstWhere((entry) => entry.nameAr == 'الفجر');
  return NextPrayerInfo(next: fajr, current: current, remaining: fajr.dateTime.difference(now));
}

PrayerTimeEntry? getCurrentPrayer(List<PrayerTimeEntry> times, DateTime now) {
  PrayerTimeEntry? current;
  for (final entry in times) {
    if (!entry.isSalah) continue;
    if (!entry.dateTime.isAfter(now)) current = entry;
  }
  return current;
}

PrayerTimeEntry? getNextPrayer(List<PrayerTimeEntry> times, DateTime now) {
  for (final entry in times) {
    if (!entry.isSalah) continue;
    if (entry.dateTime.isAfter(now)) return entry;
  }
  return null;
}

Duration? countdownToNext(List<PrayerTimeEntry> times, DateTime now) {
  final next = getNextPrayer(times, now);
  if (next == null) return null;
  return next.dateTime.difference(now);
}
