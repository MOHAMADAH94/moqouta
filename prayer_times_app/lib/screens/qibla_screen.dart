import 'package:flutter/material.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final PrayerTimesService _service = PrayerTimesService();
  double? _direction;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _direction = null;
    });
    try {
      final position = await _service.getCurrentPosition();
      final dir = _service.getQiblaDirection(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          _direction = dir;
          _loading = false;
        });
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

  String _directionDescription(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'شمال';
    if (degrees >= 22.5 && degrees < 67.5) return 'شمال شرق';
    if (degrees >= 67.5 && degrees < 112.5) return 'شرق';
    if (degrees >= 112.5 && degrees < 157.5) return 'جنوب شرق';
    if (degrees >= 157.5 && degrees < 202.5) return 'جنوب';
    if (degrees >= 202.5 && degrees < 247.5) return 'جنوب غرب';
    if (degrees >= 247.5 && degrees < 292.5) return 'غرب';
    return 'شمال غرب';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : _direction == null
                  ? const Center(child: Text('لا تتوفر بيانات'))
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.explore,
                                size: 120,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '${_direction!.toStringAsFixed(1)}°',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _directionDescription(_direction!),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'اتجه نحو الكعبة بالزاوية أعلاه من الشمال (0° = شمال، 90° = شرق، 270° = غرب)',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}
