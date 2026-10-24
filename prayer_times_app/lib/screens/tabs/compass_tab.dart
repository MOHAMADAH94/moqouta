import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';

class CompassTab extends StatefulWidget {
  const CompassTab({super.key});

  @override
  State<CompassTab> createState() => _CompassTabState();
}

class _CompassTabState extends State<CompassTab> {
  StreamSubscription<CompassEvent>? _heading;
  double? _degrees;
  double? _firstHeading;
  double _swing = 0;

  @override
  void initState() {
    super.initState();
    try {
      _heading = FlutterCompass.events?.listen(
        (event) {
          final heading = event.heading;
          if (heading == null || !mounted) return;
          _firstHeading ??= heading;
          final delta = (heading - _firstHeading!).abs();
          if (delta > _swing) _swing = delta;
          // المحاكي يعيد صفراً ثابتاً. الهاتف الحقيقي يتغير بمجرد الإمساك به.
          if (_swing < 2) return;
          setState(() => _degrees = heading);
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _heading?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final colors = context.mq;
    if (!app.manualLocation && app.gpsPlace == null) {
      return Center(
        child: Text(
          app.gpsError ?? 'جاري تحديد اتجاه القبلة...',
          style: TextStyle(color: colors.muted),
          textAlign: TextAlign.center,
        ),
      );
    }
    final place = app.place;
    final qibla = PrayerTimesService().getQiblaDirection(place.latitude, place.longitude);
    // إن لم تتوفر البوصلة نعرض الحالة المطابقة للصورة: الكعبة أعلى المؤشر.
    final heading = _degrees ?? qibla;
    final aligned = _angleBetween(heading, qibla) <= 12;
    final turn = _angleBetween(heading, qibla);
    final clockwise = _clockwise(heading, qibla);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _CompassPainter(
              qibla: qibla,
              heading: heading,
              gold: colors.gold,
              text: colors.text,
            ),
          ),
        ),
        GoldCard(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Column(
            children: [
              Text(
                aligned ? 'أنت باتجاه القبلة' : '${qibla.toStringAsFixed(1)}° من الشمال',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.text, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                aligned ? 'تقبّل الله صلاتك' : 'أدر الهاتف ${clockwise ? 'يميناً' : 'يساراً'} ${turn.round()}° حتى تلتقي الكعبة بالمؤشر',
                textAlign: TextAlign.center,
                style: TextStyle(color: aligned ? colors.gold : colors.muted, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Divider(color: colors.gold.withValues(alpha: 0.85), thickness: 1)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: MiniStar(size: 11)),
                  Expanded(child: Divider(color: colors.gold.withValues(alpha: 0.85), thickness: 1)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${bearingName(qibla)} · ${place.name}',
                style: TextStyle(color: colors.text, fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'لدقة أفضل: أبعد الهاتف عن المعادن وحرّكه على شكل رقم 8 للمعايرة',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

double _angleBetween(double from, double to) {
  final delta = ((to - from) % 360 + 360) % 360;
  return delta > 180 ? 360 - delta : delta;
}

bool _clockwise(double from, double to) {
  final delta = ((to - from) % 360 + 360) % 360;
  return delta <= 180;
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.qibla, required this.heading, required this.gold, required this.text});

  final double qibla;
  final double heading;
  final Color gold;
  final Color text;

  static const _face = Color(0xFF0C221C);

  Offset _at(Offset center, double bearing, double radius) {
    final theta = (bearing - heading) * math.pi / 180;
    return Offset(center.dx + radius * math.sin(theta), center.dy - radius * math.cos(theta));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.40;
    final center = Offset(size.width / 2, radius + 20);

    final pointer = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx - 10, center.dy - radius - 15)
      ..lineTo(center.dx + 10, center.dy - radius - 15)
      ..close();
    canvas.drawPath(pointer, Paint()..color = gold);

    canvas.drawCircle(center, radius, Paint()..color = _face);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    for (var i = 0; i < 72; i++) {
      final bearing = i * 5.0;
      final major = i % 9 == 0;
      canvas.drawLine(
        _at(center, bearing, radius - (major ? 14 : 8)),
        _at(center, bearing, radius - 3.5),
        Paint()
          ..color = major ? gold : gold.withValues(alpha: 0.55)
          ..strokeWidth = major ? 1.7 : 1,
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((qibla - heading) * math.pi / 180);
    canvas.drawPath(
      khatam(Offset.zero, radius * 0.46),
      Paint()
        ..color = gold.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeJoin = StrokeJoin.miter,
    );
    canvas.restore();

    _label(canvas, 'ش', _at(center, 0, radius * 0.76), gold);
    _label(canvas, 'ق', _at(center, 90, radius * 0.76), text);
    _label(canvas, 'ج', _at(center, 180, radius * 0.78), text);
    _label(canvas, 'غ', _at(center, 270, radius * 0.76), text);

    final kaabaW = radius * 0.17;
    final kaabaH = radius * 0.19;
    final kaabaCenter = _at(center, qibla, radius * 0.60);
    final needleEnd = _at(center, qibla, radius * 0.60 - kaabaH / 2);
    final tailEnd = _at(center, qibla + 180, radius * 0.17);
    canvas.drawLine(
      center,
      tailEnd,
      Paint()
        ..color = const Color(0xFFC5D4CC)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = gold
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, radius * 0.04, Paint()..color = _face);
    canvas.drawCircle(
      center,
      radius * 0.04,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    canvas.save();
    canvas.translate(kaabaCenter.dx, kaabaCenter.dy);
    final kaabaRect = Rect.fromCenter(center: Offset.zero, width: kaabaW, height: kaabaH);
    final kaaba = RRect.fromRectAndRadius(kaabaRect, const Radius.circular(2.5));
    canvas.drawRRect(kaaba, Paint()..color = const Color(0xFF101010));
    canvas.drawRRect(
      kaaba,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawRect(
      Rect.fromLTWH(kaabaRect.left + kaabaW * 0.12, kaabaRect.top + kaabaH * 0.28, kaabaW * 0.76, kaabaH * 0.11),
      Paint()..color = gold,
    );
    canvas.restore();
  }

  void _label(Canvas canvas, String value, Offset offset, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(color: color, fontSize: 16, fontFamily: 'Cairo', fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    painter.paint(canvas, offset - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.qibla != qibla || oldDelegate.heading != heading || oldDelegate.gold != gold;
  }
}
