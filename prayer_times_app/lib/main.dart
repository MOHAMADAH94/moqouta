import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prayer_times_app/core/app_state.dart';
import 'package:prayer_times_app/core/app_theme.dart';
import 'package:prayer_times_app/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrayerTimesApp());
}

class PrayerTimesApp extends StatefulWidget {
  const PrayerTimesApp({super.key});

  @override
  State<PrayerTimesApp> createState() => _PrayerTimesAppState();
}

class _PrayerTimesAppState extends State<PrayerTimesApp> {
  final AppController _controller = AppController();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final dark = _controller.darkMode;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: MaterialApp(
              title: 'موقوتا',
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },
              home: const MainScreen(),
            ),
          );
        },
      ),
    );
  }
}
