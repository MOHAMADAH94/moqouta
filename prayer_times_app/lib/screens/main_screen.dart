import 'package:flutter/material.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/screens/about_screen.dart';
import 'package:prayer_times_app/screens/settings_screen.dart';
import 'package:prayer_times_app/screens/tabs/compass_tab.dart';
import 'package:prayer_times_app/screens/tabs/location_tab.dart';
import 'package:prayer_times_app/screens/tabs/notifications_tab.dart';
import 'package:prayer_times_app/screens/tabs/world_cities_tab.dart';
import 'package:prayer_times_app/widgets/moqouta_ui.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _tabs = [
    _NavItem(glyph: MoqoutaGlyph.mosque, label: 'المواقيت', title: 'موقوتا'),
    _NavItem(glyph: MoqoutaGlyph.compass, label: 'القبلة', title: 'اتجاه القبلة'),
    _NavItem(glyph: MoqoutaGlyph.bell, label: 'التنبيهات', title: 'التنبيهات'),
    _NavItem(glyph: MoqoutaGlyph.globe, label: 'مدن العالم', title: 'توقيت مدن العالم'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.mq;
    final tab = _tabs[_index];
    return PatternBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 12, 0),
                child: Row(
                  children: [
                    StarBadge(glyph: tab.glyph, size: 46),
                    const SizedBox(width: 8),
                    Text(tab.title, style: TextStyle(color: colors.text, fontSize: 22, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                      },
                      icon: Icon(Icons.info_outline, color: colors.gold),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      },
                      icon: Icon(Icons.settings_outlined, color: colors.gold),
                    ),
                  ],
                ),
              ),
              const MiniStar(size: 8),
              const SizedBox(height: 4),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: const [
                    LocationTab(),
                    CompassTab(),
                    NotificationsTab(),
                    WorldCitiesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.card,
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final item = _tabs[i];
                  final selected = i == _index;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _index = i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (selected)
                            StarBadge(glyph: item.glyph, size: 32, filled: true, iconColor: colors.background)
                          else
                            GlyphIcon(item.glyph, size: 24, color: const Color(0xFFC5D1CA)),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? colors.gold : const Color(0xFFC5D1CA),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.glyph, required this.label, required this.title});

  final MoqoutaGlyph glyph;
  final String label;
  final String title;
}
