import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_times_app/core/hijri_date.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';

void main() {
  test('Hijri date matches the reference app on 24 Oct 2026', () {
    final hijri = HijriDate.fromGregorian(DateTime(2026, 10, 24));
    expect(hijri.label, '13 جمادى الأولى 1448 هـ');
  });

  test('Damascus prayer times use the Syrian awqaf angles', () {
    final times = PrayerTimesService().getPrayerTimes(
      latitude: 33.5138,
      longitude: 36.2765,
      date: DateTime(2026, 10, 24, 12),
    );
    expect(times.map((entry) => '${entry.nameAr} ${formatTime12(entry.dateTime)}').toList(), [
      'الفجر 5:16 ص',
      'الشروق 6:47 ص',
      'الظهر 12:20 م',
      'العصر 3:26 م',
      'المغرب 5:51 م',
      'العشاء 7:12 م',
    ]);
    final qibla = PrayerTimesService().getQiblaDirection(33.5138, 36.2765);
    expect(qibla, closeTo(164.5, 1));
  });
}
