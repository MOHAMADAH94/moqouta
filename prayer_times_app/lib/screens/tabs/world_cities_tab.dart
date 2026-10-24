import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/data/world_cities.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';

class WorldCitiesTab extends StatelessWidget {
  const WorldCitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: worldCities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final city = worldCities[index];
        return Material(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openCity(context, city),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.gold.withValues(alpha: 0.55)),
              ),
              child: Row(
                children: [
                  const StarBadge(glyph: MoqoutaGlyph.globe, size: 40, filled: true, fill: Color(0xFF3FB58F), iconColor: Color(0xFFF6F3EA)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(city.nameAr, style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(city.countryAr, style: TextStyle(color: colors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: colors.gold),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openCity(BuildContext context, WorldCity city) {
    final app = AppScope.of(context);
    final service = PrayerTimesService();
    final times = service.getPrayerTimes(
      latitude: city.latitude,
      longitude: city.longitude,
      date: DateTime.now(),
      methodId: app.methodId,
      madhab: app.madhab,
      offsets: app.offsets,
    );
    showMoqoutaSheet(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: context.mq.muted, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 12),
          Text(city.nameAr, style: TextStyle(color: context.mq.text, fontSize: 24, fontWeight: FontWeight.w800)),
          Text(city.countryAr, style: TextStyle(color: context.mq.muted)),
          Divider(color: context.mq.gold.withValues(alpha: 0.7)),
          ...times.map(
            (entry) => PrayerTimeTile(
              name: entry.nameAr,
              time: formatTime(entry.dateTime),
              icon: prayerGlyph(entry.nameAr),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الأوقات معروضة بتوقيت جهازك',
            style: TextStyle(color: context.mq.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
