import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/screens/location_sheet.dart';
import 'package:prayer_times_app/services/prayer_times_service.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final colors = context.mq;
    const prayers = ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    return PatternBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('الإعدادات'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _Heading(icon: Icons.place_outlined, title: 'الموقع'),
            GoldCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.manualLocation ? 'مدينة محددة يدوياً' : 'تحديد تلقائي (GPS)',
                          style: TextStyle(color: colors.text, fontWeight: FontWeight.w700),
                        ),
                        Text(app.place.name, style: TextStyle(color: colors.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => showLocationSheet(context),
                    child: Text('تغيير', style: TextStyle(color: colors.gold, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Heading(icon: Icons.calculate_outlined, title: 'طريقة الحساب'),
            GoldCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () => _pickMethod(context, app),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              app.method.nameAr,
                              style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: colors.gold),
                        ],
                      ),
                      if (app.method.description != null) ...[
                        const SizedBox(height: 8),
                        Text(app.method.description!, textAlign: TextAlign.right, style: TextStyle(color: colors.muted, fontSize: 12, height: 1.5)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _Heading(icon: Icons.menu_book_outlined, title: 'مذهب حساب العصر'),
            GoldCard(
              child: Column(
                children: [
                  _MadhabRow(
                    label: 'الشافعي (الجمهور)',
                    selected: app.madhab == Madhab.shafi,
                    onTap: () => app.setMadhab(Madhab.shafi),
                  ),
                  _MadhabRow(
                    label: 'الحنفي',
                    selected: app.madhab == Madhab.hanafi,
                    onTap: () => app.setMadhab(Madhab.hanafi),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Heading(icon: Icons.tune, title: 'تعديل المواقيت يدوياً'),
            GoldCard(
              child: Column(
                children: [
                  Text(
                    'أضف أو انقص دقائق لمطابقة تقويم مسجدك المحلي.',
                    style: TextStyle(color: colors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...prayers.map((name) => _OffsetRow(name: name, value: app.offsets.forName(name), onChanged: (value) => app.setOffset(name, value))),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Heading(icon: Icons.dark_mode_outlined, title: 'المظهر'),
            GoldCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('الوضع الليلي', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800)),
                        Text('ألوان داكنة مريحة للعين', style: TextStyle(color: colors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: app.darkMode,
                    activeThumbColor: colors.background,
                    activeTrackColor: colors.gold,
                    onChanged: app.setDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Heading(icon: Icons.widgets_outlined, title: 'ويدجت الشاشة الرئيسية'),
            const GoldCard(
              child: Text(
                'اضغط مطولاً على الشاشة الرئيسية للجهاز ثم اختر "الأدوات" (Widgets) وابحث عن "موقوتا". يتوفر حجمان: صغير للصلاة القادمة، وعريض لجميع المواقيت.',
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await app.resetAdjustments();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إعادة ضبط طريقة الحساب والتعديلات')));
                }
              },
              child: Text('إعادة الضبط', style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMethod(BuildContext context, AppController app) {
    return showMoqoutaSheet(
      context,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('طريقة الحساب', textAlign: TextAlign.center, style: TextStyle(color: context.mq.text, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...prayerMethodOptions.map((option) {
            final selected = option.id == app.methodId;
            return ListTile(
              title: Text(option.nameAr, textAlign: TextAlign.right, style: TextStyle(color: context.mq.text)),
              trailing: selected ? Icon(Icons.check, color: context.mq.gold) : null,
              onTap: () {
                Navigator.pop(context);
                app.setMethod(option.id);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: colors.gold, size: 18),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: colors.gold, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
    );
  }
}

class _MadhabRow extends StatelessWidget {
  const _MadhabRow({required this.label, required this.selected, required this.onTap});

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
            Text(label, style: TextStyle(color: colors.text, fontSize: 16)),
            const Spacer(),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: colors.gold),
          ],
        ),
      ),
    );
  }
}

class _OffsetRow extends StatelessWidget {
  const _OffsetRow({required this.name, required this.value, required this.onChanged});

  final String name;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(name, style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          _RoundButton(icon: Icons.remove, onTap: () => onChanged(value - 1)),
          const SizedBox(width: 8),
          Text('$value د', style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          _RoundButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.mint),
        ),
        child: Icon(icon, size: 16, color: colors.mint),
      ),
    );
  }
}
