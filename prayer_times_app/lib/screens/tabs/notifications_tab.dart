import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/core/prefs_keys.dart';
import 'package:prayer_times_app/services/notification_service.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final colors = context.mq;
    final minutes = app.remindBefore ? app.minutesBefore : app.minutesAfter;
    const prayers = [
      MapEntry(PrayerPrefsKeys.notifyFajr, 'الفجر'),
      MapEntry(PrayerPrefsKeys.notifyDhuhr, 'الظهر'),
      MapEntry(PrayerPrefsKeys.notifyAsr, 'العصر'),
      MapEntry(PrayerPrefsKeys.notifyMaghrib, 'المغرب'),
      MapEntry(PrayerPrefsKeys.notifyIsha, 'العشاء'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        GoldCard(
          child: Row(
            children: [
              const StarBadge(glyph: MoqoutaGlyph.bell, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تفعيل التنبيهات', style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('تُجدول لسبعة أيام قادمة', style: TextStyle(color: colors.muted, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: app.notificationsEnabled,
                activeThumbColor: colors.gold,
                activeTrackColor: colors.mint,
                onChanged: app.setNotifications,
              ),
            ],
          ),
        ),
        const SectionTitle('دخول الوقت'),
        GoldCard(
          child: Column(
            children: [
              Row(
                children: [
                  const StarBadge(glyph: MoqoutaGlyph.speaker, size: 42),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('صوت التكبيرات', style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w800)),
                        Text('تكبيرات الأذان عند حلول موعد كل صلاة', style: TextStyle(color: colors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: app.takbeerEnabled,
                    activeThumbColor: colors.gold,
                    activeTrackColor: colors.mint,
                    onChanged: app.setTakbeer,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: NotificationService.previewTakbeer,
                  icon: Icon(Icons.play_circle_outline, color: colors.gold),
                  label: Text('تجربة الصوت', style: TextStyle(color: colors.gold)),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('تذكير إضافي'),
        GoldCard(
          child: Column(
            children: [
              _RadioRow(
                label: 'قبل الأذان',
                selected: app.remindBefore,
                onTap: () => app.setRemindBefore(true),
              ),
              _RadioRow(
                label: 'عند الأذان أو بعده',
                selected: !app.remindBefore,
                onTap: () => app.setRemindBefore(false),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  Text(app.remindBefore ? 'دقائق قبل الأذان' : 'دقائق بعد الأذان', style: TextStyle(color: colors.muted)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colors.mint,
                        inactiveTrackColor: colors.line,
                        thumbColor: colors.gold,
                        overlayColor: colors.gold.withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: minutes.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 60,
                        onChanged: (value) => app.setRemindMinutes(value.round()),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.gold),
                    ),
                    child: Text('$minutes د', style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionTitle('الصلوات'),
        GoldCard(
          child: Column(
            children: prayers.map((entry) {
              final checked = app.prayerToggles[entry.key] ?? true;
              return InkWell(
                onTap: () => app.setPrayerToggle(entry.key, !checked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(entry.value, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700, fontSize: 16)),
                      const Spacer(),
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: checked ? colors.mint : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: checked ? colors.mint : colors.muted, width: 1.6),
                        ),
                        child: checked ? const Icon(Icons.check, size: 16, color: Color(0xFFF6F3EA)) : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: colors.gold),
            const SizedBox(width: 8),
            Expanded(child: Text(label, textAlign: TextAlign.right, style: TextStyle(color: colors.text, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
