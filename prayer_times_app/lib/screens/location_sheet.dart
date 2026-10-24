import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/data/syrian_cities.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';

Future<void> showLocationSheet(BuildContext context) {
  final app = AppScope.of(context);
  return showMoqoutaSheet(
    context,
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: Builder(
        builder: (context) {
        final colors = context.mq;
        return ListView(
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 12),
            Text('اختر موقعك', textAlign: TextAlign.center, style: TextStyle(color: colors.text, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _ChoiceTile(
              title: 'تحديد تلقائي (GPS)',
              subtitle: 'الأدق: يحسب المواقيت لإحداثياتك الفعلية',
              icon: Icons.my_location,
              selected: !app.manualLocation,
              onTap: () {
                Navigator.pop(context);
                app.useGps();
              },
            ),
            const SectionTitle('المحافظات السورية'),
            ...syrianCities.map((city) {
              final selected = app.manualLocation && app.cityId == city.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ChoiceTile(
                  title: city.nameAr,
                  icon: Icons.location_city_outlined,
                  selected: selected,
                  onTap: () {
                    Navigator.pop(context);
                    app.useManualCity(city.id);
                  },
                ),
              );
            }),
          ],
        );
        },
      ),
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? colors.gold : colors.gold.withValues(alpha: 0.45), width: selected ? 1.6 : 1),
          ),
          child: Row(
            children: [
              StarBadge(icon: icon, size: 36, filled: selected),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700, fontSize: 16)),
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(color: colors.muted, fontSize: 12)),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: colors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
