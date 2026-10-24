import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/prefs_keys.dart';
import 'package:prayer_times_app/screens/qibla_screen.dart';
import 'package:prayer_times_app/screens/settings_screen.dart';
import 'package:prayer_times_app/services/notification_service.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesService _service = PrayerTimesService();
  List<PrayerTimeEntry>? _times;
  bool _loading = true;
  String? _error;
  Duration? _countdown;
  PrayerTimeEntry? _nextPrayer;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    // تحديث العد التنازلي كل دقيقة
    Future.delayed(const Duration(seconds: 1), _updateCountdown);
  }

  void _updateCountdown() {
    if (!mounted || _times == null) return;
    final now = DateTime.now();
    _nextPrayer = getNextPrayer(_times!, now);
    setState(() {
      _countdown = countdownToNext(_times!, now);
    });
    Future.delayed(const Duration(seconds: 30), _updateCountdown);
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _service.getCurrentPosition();
      final prefs = await SharedPreferences.getInstance();
      final madhabStr = prefs.getString(PrayerPrefsKeys.madhab);
      final methodStr = prefs.getString(PrayerPrefsKeys.calculationMethod);
      final madhab = _parseMadhab(madhabStr);
      final method = _parseMethod(methodStr);
      final times = _service.getTodayPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        method: method,
        madhab: madhab,
      );
      if (mounted) {
        setState(() {
          _times = times;
          _loading = false;
          _nextPrayer = getNextPrayer(times, DateTime.now());
          _countdown = countdownToNext(times, DateTime.now());
        });
        NotificationService.schedulePrayerNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadPrayerTimes,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    if (_times == null || _times!.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final now = DateTime.now();
    final hijriYear = ((now.year - 622) * (33 / 32)).round();
    final hijriText = 'سنة $hijriYear هـ';
    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التاريخ الهجري',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Expanded(
                    child: Text(
                      hijriText,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_nextPrayer != null && _countdown != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصلاة القادمة: ${_nextPrayer!.nameAr}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatTime(_nextPrayer!.dateTime),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCountdown(_countdown!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Card(
            child: ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('اتجاه القبلة'),
              subtitle: const Text('معرفة اتجاه الكعبة'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QiblaScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'مواقيت اليوم',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ..._times!.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    title: Text(t.nameAr),
                    trailing: Text(
                      formatTime(t.dateTime),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات الصيام (رمضان)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'وقت الإمساك = الفجر · وقت الإفطار = المغرب',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Madhab _parseMadhab(String? s) {
    if (s == null) return Madhab.shafi;
    for (final e in Madhab.values) {
      if (e.name == s) return e;
    }
    return Madhab.shafi;
  }

  CalculationMethod _parseMethod(String? s) {
    if (s == null) return CalculationMethod.muslim_world_league;
    for (final e in CalculationMethod.values) {
      if (e.name == s) return e;
    }
    return CalculationMethod.muslim_world_league;
  }

  String _formatCountdown(Duration d) {
    if (d.isNegative) return '--';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return 'بعد $h ساعة و $m دقيقة';
    return 'بعد $m دقيقة';
  }
}
