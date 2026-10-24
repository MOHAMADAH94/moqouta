import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/app_theme.dart';

class PatternBackground extends StatelessWidget {
  const PatternBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.background)),
        const Positioned.fill(child: CustomPaint(painter: GeometryPatternPainter())),
        child,
      ],
    );
  }
}

class GeometryPatternPainter extends CustomPainter {
  const GeometryPatternPainter({this.color = const Color(0x26D4AF37)});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95
      ..strokeJoin = StrokeJoin.round;
    const cell = 74.0;
    const starR = 10.5;
    for (var y = 0.0; y <= size.height + cell; y += cell) {
      for (var x = 0.0; x <= size.width + cell; x += cell) {
        final center = Offset(x, y);
        canvas.drawPath(khatam(center, starR), paint);
        canvas.drawLine(Offset(x + starR, y), Offset(x + cell - starR, y), paint);
        canvas.drawLine(Offset(x, y + starR), Offset(x, y + cell - starR), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GeometryPatternPainter oldDelegate) => oldDelegate.color != color;
}

/// النجمة الثمانية الإسلامية (مربعان متداخلان) كما في التطبيق السابق.
Path khatam(Offset center, double radius) {
  Path square(double rotation) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = rotation + i * math.pi / 2;
      final point = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  return Path.combine(PathOperation.union, square(0), square(math.pi / 4));
}

enum MoqoutaGlyph { fajr, sunrise, dhuhr, asr, maghrib, isha, mosque, compass, bell, globe, speaker }

IconData glyphIcon(MoqoutaGlyph glyph) {
  switch (glyph) {
    case MoqoutaGlyph.fajr:
      return Icons.wb_twilight;
    case MoqoutaGlyph.sunrise:
      return Icons.wb_sunny_outlined;
    case MoqoutaGlyph.dhuhr:
      return Icons.wb_sunny;
    case MoqoutaGlyph.asr:
      return Icons.cloud;
    case MoqoutaGlyph.maghrib:
      return Icons.water_drop;
    case MoqoutaGlyph.isha:
      return Icons.dark_mode;
    case MoqoutaGlyph.mosque:
      return Icons.mosque;
    case MoqoutaGlyph.compass:
      return Icons.explore;
    case MoqoutaGlyph.bell:
      return Icons.notifications_none;
    case MoqoutaGlyph.globe:
      return Icons.public;
    case MoqoutaGlyph.speaker:
      return Icons.volume_up;
  }
}

class StarBadge extends StatelessWidget {
  const StarBadge({
    super.key,
    this.icon,
    this.glyph,
    this.size = 42,
    this.filled = false,
    this.fill,
    this.iconColor,
  });

  final IconData? icon;
  final MoqoutaGlyph? glyph;
  final double size;
  final bool filled;
  final Color? fill;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    final mark = iconColor ?? (filled ? const Color(0xFFF6F3EA) : colors.gold);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: StarPainter(color: fill ?? colors.gold, filled: filled),
        child: Center(
          child: Icon(icon ?? (glyph == null ? Icons.circle : glyphIcon(glyph!)), size: size * 0.42, color: mark),
        ),
      ),
    );
  }
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(this.glyph, {super.key, this.size = 24, required this.color});

  final MoqoutaGlyph glyph;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(glyphIcon(glyph), size: size, color: color);
  }
}

class StarPainter extends CustomPainter {
  StarPainter({required this.color, this.filled = false, this.stroke = 1.3});

  final Color color;
  final bool filled;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = khatam(Offset(size.width / 2, size.height / 2), size.width * 0.46);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}

class GoldCard extends StatelessWidget {
  const GoldCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.emphasized = false});

  final Widget child;
  final EdgeInsets padding;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return OrnamentFrame(padding: padding, emphasized: emphasized, child: child);
  }
}

class OrnamentFrame extends StatelessWidget {
  const OrnamentFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    this.emphasized = false,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool emphasized;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.gold, width: emphasized ? 1.6 : 1.1),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.gold.withValues(alpha: 0.55))),
          const SizedBox(width: 8),
          const MiniStar(size: 10),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(width: 8),
          const MiniStar(size: 10),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: colors.gold.withValues(alpha: 0.55))),
        ],
      ),
    );
  }
}

class MiniStar extends StatelessWidget {
  const MiniStar({super.key, this.size = 10, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: StarPainter(color: color ?? context.mq.gold, filled: true),
    );
  }
}

class PrayerTimeTile extends StatelessWidget {
  const PrayerTimeTile({
    super.key,
    required this.name,
    required this.time,
    required this.icon,
    this.badge,
    this.emphasized = false,
  });

  final String name;
  final String time;
  final MoqoutaGlyph icon;
  final String? badge;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    final starFill = emphasized ? colors.gold : colors.mint;
    final coming = badge == 'القادمة';
    final now = badge == 'الآن';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OrnamentFrame(
        emphasized: emphasized,
        child: Row(
          children: [
            StarBadge(glyph: icon, size: 42, filled: true, fill: starFill, iconColor: const Color(0xFFF6F3EA)),
            const SizedBox(width: 10),
            Text(name, style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w700)),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: coming ? colors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: now ? colors.mint : colors.gold),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: coming ? colors.background : (now ? colors.mint : colors.gold),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Text(time, style: TextStyle(color: colors.mint, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

MoqoutaGlyph prayerGlyph(String name) {
  switch (name) {
    case 'الفجر':
      return MoqoutaGlyph.fajr;
    case 'الشروق':
      return MoqoutaGlyph.sunrise;
    case 'الظهر':
      return MoqoutaGlyph.dhuhr;
    case 'العصر':
      return MoqoutaGlyph.asr;
    case 'المغرب':
      return MoqoutaGlyph.maghrib;
    case 'العشاء':
      return MoqoutaGlyph.isha;
    default:
      return MoqoutaGlyph.dhuhr;
  }
}

Future<T?> showMoqoutaSheet<T>(BuildContext context, {required Widget child}) {
  final colors = context.mq;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: child,
      );
    },
  );
}
