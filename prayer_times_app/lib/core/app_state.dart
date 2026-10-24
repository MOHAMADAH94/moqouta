import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:prayer_times_app/core/prefs_keys.dart';
import 'package:prayer_times_app/data/syrian_cities.dart';
import 'package:prayer_times_app/services/notification_service.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';
import 'package:prayer_times_app/services/widget_publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPlace {
  const AppPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.manual,
  });

  final String name;
  final double latitude;
  final double longitude;
  final bool manual;
}

class AppController extends ChangeNotifier {
  final PrayerTimesService _service = PrayerTimesService();

  bool ready = false;
  bool darkMode = true;
  bool manualLocation = true;
  String cityId = 'damascus';
  String methodId = 'syrian_awqaf';
  Madhab madhab = Madhab.shafi;
  MinuteOffsets offsets = const MinuteOffsets();
  bool notificationsEnabled = true;
  bool takbeerEnabled = true;
  bool remindBefore = true;
  int minutesBefore = 10;
  int minutesAfter = 0;
  final Map<String, bool> prayerToggles = {
    PrayerPrefsKeys.notifyFajr: true,
    PrayerPrefsKeys.notifyDhuhr: true,
    PrayerPrefsKeys.notifyAsr: true,
    PrayerPrefsKeys.notifyMaghrib: true,
    PrayerPrefsKeys.notifyIsha: true,
  };

  AppPlace? gpsPlace;
  String? gpsError;
  bool locating = false;

  AppPlace get place {
    if (!manualLocation && gpsPlace != null) return gpsPlace!;
    final city = syrianCityById(cityId);
    return AppPlace(
      name: city.shortName,
      latitude: city.latitude,
      longitude: city.longitude,
      manual: true,
    );
  }

  SyrianCity get selectedCity => syrianCityById(cityId);

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (ready) WidgetPublisher.push(this);
  }

  PrayerMethodOption get method => prayerMethodById(methodId);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(PrayerPrefsKeys.darkMode) ?? true;
    manualLocation = (prefs.getString(PrayerPrefsKeys.locationMode) ?? 'manual') != 'gps';
    cityId = prefs.getString(PrayerPrefsKeys.cityId) ?? 'damascus';
    methodId = prefs.getString(PrayerPrefsKeys.calculationMethod) ?? 'syrian_awqaf';
    madhab = _madhab(prefs.getString(PrayerPrefsKeys.madhab));
    offsets = MinuteOffsets(
      fajr: prefs.getInt(PrayerPrefsKeys.offsetFajr) ?? 0,
      sunrise: prefs.getInt(PrayerPrefsKeys.offsetSunrise) ?? 0,
      dhuhr: prefs.getInt(PrayerPrefsKeys.offsetDhuhr) ?? 0,
      asr: prefs.getInt(PrayerPrefsKeys.offsetAsr) ?? 0,
      maghrib: prefs.getInt(PrayerPrefsKeys.offsetMaghrib) ?? 0,
      isha: prefs.getInt(PrayerPrefsKeys.offsetIsha) ?? 0,
    );
    notificationsEnabled = prefs.getBool(PrayerPrefsKeys.notificationsEnabled) ?? true;
    takbeerEnabled = prefs.getBool(PrayerPrefsKeys.takbeerEnabled) ?? true;
    remindBefore = prefs.getBool(PrayerPrefsKeys.notifyTiming) ?? true;
    minutesBefore = prefs.getInt(PrayerPrefsKeys.notifyBeforeMinutes) ?? 10;
    minutesAfter = prefs.getInt(PrayerPrefsKeys.notifyAfterMinutes) ?? 0;
    for (final key in prayerToggles.keys) {
      prayerToggles[key] = prefs.getBool(key) ?? true;
    }
    ready = true;
    notifyListeners();
    await NotificationService.init();
    if (notificationsEnabled) {
      await _reschedule();
    }
    if (!manualLocation) {
      await refreshGps();
    }
  }

  Madhab _madhab(String? value) {
    if (value == Madhab.hanafi.name) return Madhab.hanafi;
    return Madhab.shafi;
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrayerPrefsKeys.darkMode, value);
  }

  Future<void> useManualCity(String id) async {
    manualLocation = true;
    cityId = id;
    gpsError = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrayerPrefsKeys.locationMode, 'manual');
    await prefs.setString(PrayerPrefsKeys.cityId, id);
    await _reschedule();
  }

  Future<void> useGps() async {
    manualLocation = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrayerPrefsKeys.locationMode, 'gps');
    await refreshGps();
  }

  Future<void> refreshGps() async {
    locating = true;
    gpsError = null;
    notifyListeners();
    try {
      final position = await _service.getCurrentPosition();
      var name = 'موقعك الحالي';
      try {
        final marks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (marks.isNotEmpty) {
          final mark = marks.first;
          name = mark.locality ?? mark.subAdministrativeArea ?? mark.administrativeArea ?? name;
        }
      } catch (_) {}
      gpsPlace = AppPlace(
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
        manual: false,
      );
    } catch (error) {
      gpsError = error.toString().replaceFirst('Exception: ', '');
    } finally {
      locating = false;
      notifyListeners();
      await _reschedule();
    }
  }

  Future<void> setMethod(String id) async {
    methodId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrayerPrefsKeys.calculationMethod, id);
    await _reschedule();
  }

  Future<void> setMadhab(Madhab value) async {
    madhab = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrayerPrefsKeys.madhab, value.name);
    await _reschedule();
  }

  Future<void> setOffset(String name, int value) async {
    final clamped = value.clamp(-60, 60);
    offsets = offsets.copyWithName(name, clamped);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    const keys = {
      'الفجر': PrayerPrefsKeys.offsetFajr,
      'الشروق': PrayerPrefsKeys.offsetSunrise,
      'الظهر': PrayerPrefsKeys.offsetDhuhr,
      'العصر': PrayerPrefsKeys.offsetAsr,
      'المغرب': PrayerPrefsKeys.offsetMaghrib,
      'العشاء': PrayerPrefsKeys.offsetIsha,
    };
    await prefs.setInt(keys[name]!, clamped);
    await _reschedule();
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrayerPrefsKeys.notificationsEnabled, value);
    if (value) {
      await NotificationService.requestPermission();
      await _reschedule();
    } else {
      await NotificationService.cancelAll();
    }
  }

  Future<void> setTakbeer(bool value) async {
    takbeerEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrayerPrefsKeys.takbeerEnabled, value);
    await _reschedule();
  }

  Future<void> setRemindBefore(bool value) async {
    remindBefore = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrayerPrefsKeys.notifyTiming, value);
    await _reschedule();
  }

  Future<void> setRemindMinutes(int value) async {
    final clamped = value.clamp(0, 60);
    if (remindBefore) {
      minutesBefore = clamped;
    } else {
      minutesAfter = clamped;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      remindBefore ? PrayerPrefsKeys.notifyBeforeMinutes : PrayerPrefsKeys.notifyAfterMinutes,
      clamped,
    );
    await _reschedule();
  }

  Future<void> setPrayerToggle(String key, bool value) async {
    prayerToggles[key] = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    await _reschedule();
  }

  Future<void> resetAdjustments() async {
    methodId = 'syrian_awqaf';
    madhab = Madhab.shafi;
    offsets = const MinuteOffsets();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrayerPrefsKeys.calculationMethod, methodId);
    await prefs.setString(PrayerPrefsKeys.madhab, madhab.name);
    await prefs.setInt(PrayerPrefsKeys.offsetFajr, 0);
    await prefs.setInt(PrayerPrefsKeys.offsetSunrise, 0);
    await prefs.setInt(PrayerPrefsKeys.offsetDhuhr, 0);
    await prefs.setInt(PrayerPrefsKeys.offsetAsr, 0);
    await prefs.setInt(PrayerPrefsKeys.offsetMaghrib, 0);
    await prefs.setInt(PrayerPrefsKeys.offsetIsha, 0);
    await _reschedule();
  }

  Future<void> _reschedule() async {
    if (!notificationsEnabled) return;
    await NotificationService.schedulePrayerNotifications();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child})
      : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope غير موجود');
    return scope!.notifier!;
  }
}
