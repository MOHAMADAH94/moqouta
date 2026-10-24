import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return PatternBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('حول التطبيق'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.elliptical(220, 80), bottom: Radius.circular(24)),
                border: Border.all(color: colors.gold),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset('assets/images/app_logo.jpg', width: 132, height: 132, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  Text('الإصدار 1.0.0', style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    'رفيقك اليومي لمعرفة أوقات الصلاة في سوريا وحول العالم',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.text, height: 1.6),
                  ),
                ],
              ),
            ),
            const SectionTitle('المطوّر'),
            GoldCard(
              child: Column(
                children: [
                  const StarBadge(icon: Icons.engineering_outlined, size: 48),
                  const SizedBox(height: 8),
                  Text('المهندس محمد أحمد حمدان', style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('تصميم وتطوير التطبيق', style: TextStyle(color: colors.muted)),
                  const SizedBox(height: 12),
                  _ContactTile(
                    title: 'تواصل عبر واتساب',
                    value: '09677770101',
                    icon: Icons.chat_outlined,
                    uri: Uri.parse('https://wa.me/9639677770101'),
                  ),
                  _ContactTile(
                    title: 'اتصال هاتفي',
                    value: '09677770101',
                    icon: Icons.phone_outlined,
                    uri: Uri.parse('tel:09677770101'),
                  ),
                  _ContactTile(
                    title: 'البريد الإلكتروني',
                    value: 'eng.mohamadah94@gmail.com',
                    icon: Icons.email_outlined,
                    uri: Uri.parse('mailto:eng.mohamadah94@gmail.com'),
                  ),
                  const SizedBox(height: 6),
                  Text('اضغط مطولاً على أي وسيلة لنسخها', style: TextStyle(color: colors.muted, fontSize: 12)),
                ],
              ),
            ),
            const SectionTitle('المميزات'),
            const GoldCard(
              child: Column(
                children: [
                  _Feature(Icons.schedule, 'مواقيت دقيقة وفق التقويم المعتمد في سوريا'),
                  _Feature(Icons.my_location_outlined, 'حساب تلقائي حسب موقعك أو اختيار المحافظة يدوياً'),
                  _Feature(Icons.explore_outlined, 'بوصلة لتحديد اتجاه القبلة'),
                  _Feature(Icons.notifications_outlined, 'تكبيرات عند دخول الوقت وتنبيهات قبل الأذان'),
                  _Feature(Icons.calendar_month_outlined, 'التاريخ الهجري والميلادي'),
                  _Feature(Icons.widgets_outlined, 'ويدجت للشاشة الرئيسية بحجمين'),
                  _Feature(Icons.wifi_off_outlined, 'يعمل دون اتصال بالإنترنت'),
                ],
              ),
            ),
            const SectionTitle('طريقة الحساب'),
            GoldCard(
              child: Text(
                'تُحسب المواقيت فلكياً لإحداثيات موقعك: الفجر عند انخفاض الشمس 19.5° والعشاء 17.5°، والعصر على المذهب الشافعي، مع احتياط دقيقة للظهر. يمكنك تغيير الطريقة أو تعديل أي وقت بالدقائق من الإعدادات لمطابقة مسجدك.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.text, height: 1.8, fontSize: 14),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              '﴿ إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا ﴾',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.text, fontSize: 16, height: 1.8, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text('سورة النساء - 103', textAlign: TextAlign.center, style: TextStyle(color: colors.gold, fontSize: 13)),
            const SizedBox(height: 16),
            Text(
              برجاء الدعاء لي ولوالديّ وقل رب ارحمهما كما ربياني صغيرا',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.muted, fontSize: 13, height: 1.7),
            ),
            const SizedBox(height: 10),
            Text(
              '© 2026 المهندس محمد أحمد حمدان',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: colors.text, height: 1.45)),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.title, required this.value, required this.icon, required this.uri});

  final String title;
  final String value;
  final IconData icon;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    return InkWell(
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened) {
          await Clipboard.setData(ClipboardData(text: value));
          messenger.showSnackBar(const SnackBar(content: Text('تعذر الفتح، تم نسخ')));
        }
      },
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نسخ $value')));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.chevron_left, color: colors.gold),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
                Text(value, style: TextStyle(color: colors.muted, fontSize: 13)),
              ],
            ),
            const SizedBox(width: 8),
            Icon(icon, color: colors.mint),
          ],
        ),
      ),
    );
  }
}
