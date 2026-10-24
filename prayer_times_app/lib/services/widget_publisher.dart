import 'package:flutter/services.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/hijri_date.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';

/// يحدّث ودجات الشاشة الرئيسية من نفس حساب المواقيت المعروض في التطبيق.
class WidgetPublisher {
  static const _channel = MethodChannel('com.islamicapps.prayer_times_app/widget');

  static Future<void> push(AppController app) async {
    if (!app.ready) return;
    final place = app.place;
    final service = PrayerTimesService();
    final now = DateTime.now();
    final today = service.getPrayerTimes(
      latitude: place.latitude,
      longitude: place.longitude,
      date: now,
      methodId: app.methodId,
      madhab: app.madhab,
      offsets: app.offsets,
    );
    final tomorrow = service.getPrayerTimes(
      latitude: place.latitude,
      longitude: place.longitude,
      date: now.add(const Duration(days: 1)),
      methodId: app.methodId,
      madhab: app.madhab,
      offsets: app.offsets,
    );
    final fajr = tomorrow.firstWhere((entry) => entry.nameAr == 'الفجر');
    String pack(PrayerTimeEntry entry) =>
        '${entry.nameAr}|${formatTime12(entry.dateTime)}|${entry.dateTime.millisecondsSinceEpoch}|${entry.isSalah ? 1 : 0}';
    try {
      await _channel.invokeMethod<void>('update', {
        'city': place.name,
        'hijri': HijriDate.fromGregorian(now).label,
        'gregorian': formatGregorian(now),
        'rows': today.map(pack).join(';'),
        'tomorrowName': fajr.nameAr,
        'tomorrowDisplay': formatTime12(fajr.dateTime),
        'tomorrowAt': fajr.dateTime.millisecondsSinceEpoch,
      });
    } on MissingPluginException {
      // سطح المكتب والاختبارات لا يملكان قناة الودجت.
    } catch (_) {}
  }
}
