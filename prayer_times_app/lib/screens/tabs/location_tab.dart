import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/core/hijri_date.dart';
import 'package:prayer_times_app/screens/location_sheet.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';

class LocationTab extends StatefulWidget {
  const LocationTab({super.key});

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab> {
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final colors = context.mq;
    if (!app.manualLocation && app.locating && app.gpsPlace == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!app.manualLocation && app.gpsPlace == null) {
      return _LocationError(message: app.gpsError ?? 'تعذر تحديد الموقع. اختر مدينتك يدوياً من الإعدادات.');
    }

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
    final next = resolveNextPrayer(today: today, tomorrow: tomorrow, now: now);
    final hijri = HijriDate.fromGregorian(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _HeroCard(
          city: place.name,
          hijri: hijri.label,
          gregorian: formatGregorian(now),
          prayerName: next.next.nameAr,
          prayerTime: formatTime12(next.next.dateTime),
          countdown: formatCountdown(next.remaining),
          progress: _remainingFraction(next),
          onCityTap: () => showLocationSheet(context),
        ),
        const SectionTitle('مواقيت اليوم'),
        ...today.map((entry) {
          String? badge;
          if (next.current?.nameAr == entry.nameAr) badge = 'الآن';
          if (next.next.nameAr == entry.nameAr && entry.dateTime.day == now.day) badge = 'القادمة';
          return PrayerTimeTile(
            name: entry.nameAr,
            time: formatTime12(entry.dateTime),
            icon: prayerGlyph(entry.nameAr),
            badge: badge,
            emphasized: badge == 'القادمة',
          );
        }),
        const SizedBox(height: 6),
        Text(
          '${app.method.nameAr} · ${app.madhab.name == 'hanafi' ? 'العصر الحنفي' : 'العصر الشافعي (الجمهور)'}',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        GoldCard(
          child: Column(
            children: [
              Text(
                '﴿ إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا ﴾',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.text, fontSize: 16, height: 1.7, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text('سورة النساء - 103', style: TextStyle(color: colors.gold, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

double _remainingFraction(NextPrayerInfo next) {
  final start = next.current?.dateTime;
  if (start == null) return 0.72;
  final span = next.next.dateTime.difference(start).inSeconds;
  if (span <= 0) return 1;
  return (next.remaining.inSeconds / span).clamp(0.05, 1.0);
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.city,
    required this.hijri,
    required this.gregorian,
    required this.prayerName,
    required this.prayerTime,
    required this.countdown,
    required this.progress,
    required this.onCityTap,
  });

  final String city;
  final String hijri;
  final String gregorian;
  final String prayerName;
  final String prayerTime;
  final String countdown;
  final double progress;
  final VoidCallback onCityTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
      painter: _ArchBorderPainter(colors.gold),
      child: ClipPath(
        clipper: const _ArchClipper(),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF135846), Color(0xFF0E4034)],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: CustomPaint(painter: GeometryPatternPainter(color: Color(0x33D4AF37)))),
            const Positioned(left: 0, right: 0, bottom: 0, height: 110, child: IgnorePointer(child: CustomPaint(painter: _MosquePainter()))),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 34, 18, 18),
              child: Column(
                children: [
          const SizedBox(height: 8),
          InkWell(
            onTap: onCityTap,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_down_rounded, color: colors.gold),
                const SizedBox(width: 4),
                Text(city, style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Icon(Icons.location_on, color: colors.gold, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(hijri, style: TextStyle(color: colors.gold, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(gregorian, style: TextStyle(color: colors.muted, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 108,
                height: 108,
                child: CustomPaint(
                  painter: _RingPainter(colors.gold, progress),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('متبق', style: TextStyle(color: colors.muted, fontSize: 12)),
                        Text(countdown, style: TextStyle(color: colors.gold, fontSize: 15, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الصلاة القادمة', style: TextStyle(color: colors.muted, fontSize: 13)),
                    Text(prayerName, style: TextStyle(color: colors.text, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1)),
                    Text(prayerTime, style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
            ],
              ),
            ),
          ],
        ),
      ),
        ),
        const Positioned(top: -8, left: 0, right: 0, child: Center(child: MiniStar(size: 14))),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.progress);

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final base = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color;
}

class _ArchClipper extends CustomClipper<Path> {
  const _ArchClipper();

  @override
  Path getClip(Size size) => _archPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ArchBorderPainter extends CustomPainter {
  _ArchBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _archPath(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchBorderPainter oldDelegate) => oldDelegate.color != color;
}

Path _archPath(Size size) {
  final w = size.width;
  final h = size.height;
  return Path()
    ..moveTo(0, h)
    ..lineTo(0, h * 0.2)
    ..cubicTo(0, h * 0.05, w * 0.22, 0, w * 0.5, 0)
    ..cubicTo(w * 0.78, 0, w, h * 0.05, w, h * 0.2)
    ..lineTo(w, h)
    ..close();
}

class _MosquePainter extends CustomPainter {
  const _MosquePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF08261C).withValues(alpha: 0.72);
    final ground = size.height * 0.62;
    canvas.drawRect(Rect.fromLTWH(0, ground, size.width, size.height - ground), paint);
    void dome(double cx, double r) {
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, ground), radius: r), math.pi, math.pi, true, paint);
    }

    dome(size.width * 0.5, size.width * 0.055);
    dome(size.width * 0.34, size.width * 0.032);
    dome(size.width * 0.66, size.width * 0.032);
    void minaret(double xFactor, double height) {
      final x = size.width * xFactor;
      final w = size.width * 0.016;
      canvas.drawRect(Rect.fromLTWH(x, ground - height, w, height), paint);
      final tip = Path()
        ..moveTo(x - w * 0.35, ground - height)
        ..lineTo(x + w / 2, ground - height - w * 2.2)
        ..lineTo(x + w * 1.35, ground - height)
        ..close();
      canvas.drawPath(tip, paint);
    }

    minaret(0.08, size.height * 0.42);
    minaret(0.2, size.height * 0.28);
    minaret(0.78, size.height * 0.28);
    minaret(0.9, size.height * 0.46);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationError extends StatelessWidget {
  const _LocationError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, color: colors.gold, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: colors.text, fontSize: 16)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => showLocationSheet(context),
              child: const Text('اختر موقعك'),
            ),
          ],
        ),
      ),
    );
  }
}
