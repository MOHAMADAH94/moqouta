import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times_app/core/prefs_keys.dart';
import 'package:prayer_times_app/data/syrian_cities.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const _sound = MethodChannel('com.islamicapps.prayer_times_app/widget');
  static bool _initialized = false;
  static const takbeerChannelId = 'moqouta_takbeer';
  static const reminderChannelId = 'prayer_channel';

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Damascus'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
        reminderChannelId,
        'تذكير الصلاة',
        description: 'التذكير قبل الأذان أو بعده',
        importance: Importance.high,
      ));
      await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
        takbeerChannelId,
        'تكبيرات الصلاة',
        description: 'التكبيرات الأربع عند دخول وقت الصلاة',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('takbeer'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ));
    }
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? true;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final result = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return result == true;
  }

  static Future<void> schedulePrayerNotifications() async {
    await init();
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(PrayerPrefsKeys.notificationsEnabled) ?? false)) return;

    final manual = (prefs.getString(PrayerPrefsKeys.locationMode) ?? 'manual') != 'gps';
    late double latitude;
    late double longitude;
    if (manual) {
      final city = syrianCityById(prefs.getString(PrayerPrefsKeys.cityId));
      latitude = city.latitude;
      longitude = city.longitude;
    } else {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (_) {
        return;
      }
    }

    final madhab = prefs.getString(PrayerPrefsKeys.madhab) == Madhab.hanafi.name ? Madhab.hanafi : Madhab.shafi;
    final methodId = prefs.getString(PrayerPrefsKeys.calculationMethod) ?? 'syrian_awqaf';
    final offsets = MinuteOffsets(
      fajr: prefs.getInt(PrayerPrefsKeys.offsetFajr) ?? 0,
      sunrise: prefs.getInt(PrayerPrefsKeys.offsetSunrise) ?? 0,
      dhuhr: prefs.getInt(PrayerPrefsKeys.offsetDhuhr) ?? 0,
      asr: prefs.getInt(PrayerPrefsKeys.offsetAsr) ?? 0,
      maghrib: prefs.getInt(PrayerPrefsKeys.offsetMaghrib) ?? 0,
      isha: prefs.getInt(PrayerPrefsKeys.offsetIsha) ?? 0,
    );
    final before = prefs.getBool(PrayerPrefsKeys.notifyTiming) ?? true;
    final minutes = before
        ? (prefs.getInt(PrayerPrefsKeys.notifyBeforeMinutes) ?? 10)
        : (prefs.getInt(PrayerPrefsKeys.notifyAfterMinutes) ?? 0);
    final takbeer = prefs.getBool(PrayerPrefsKeys.takbeerEnabled) ?? true;
    const keys = [
      PrayerPrefsKeys.notifyFajr,
      PrayerPrefsKeys.notifyDhuhr,
      PrayerPrefsKeys.notifyAsr,
      PrayerPrefsKeys.notifyMaghrib,
      PrayerPrefsKeys.notifyIsha,
    ];
    final service = PrayerTimesService();
    final now = DateTime.now();

    for (var day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      final times = service.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: date,
        methodId: methodId,
        madhab: madhab,
        offsets: offsets,
      );
      final salah = times.where((entry) => entry.isSalah).toList();
      for (var i = 0; i < salah.length; i++) {
        if (!(prefs.getBool(keys[i]) ?? true)) continue;
        final prayer = salah[i];
        if (takbeer) {
          await _schedule(
            id: day * 20 + i,
            when: prayer.dateTime,
            title: 'الله أكبر، حان الآن موعد صلاة ${prayer.nameAr}',
            body: 'دخل وقت صلاة ${prayer.nameAr}',
            takbeer: true,
          );
        }
        final reminder = before
            ? prayer.dateTime.subtract(Duration(minutes: minutes))
            : prayer.dateTime.add(Duration(minutes: minutes));
        await _schedule(
          id: 200 + day * 20 + i,
          when: reminder,
          title: 'تذكير صلاة ${prayer.nameAr}',
          body: before ? 'صلاة ${prayer.nameAr} بعد $minutes دقائق' : 'صلاة ${prayer.nameAr} منذ $minutes دقائق',
        );
      }
    }
  }

  static Future<void> _schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    bool takbeer = false,
  }) async {
    if (!when.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            takbeer ? takbeerChannelId : reminderChannelId,
            takbeer ? 'تكبيرات الصلاة' : 'تذكير الصلاة',
            importance: takbeer ? Importance.max : Importance.high,
            priority: takbeer ? Priority.max : Priority.high,
            playSound: true,
            sound: takbeer ? const RawResourceAndroidNotificationSound('takbeer') : null,
            audioAttributesUsage: takbeer ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  static Future<void> previewTakbeer() async {
    try {
      await _sound.invokeMethod<void>('playTakbeer');
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
