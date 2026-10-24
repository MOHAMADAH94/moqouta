import 'package:flutter/material.dart';

class AppThemeScope extends InheritedWidget {
  const AppThemeScope({
    super.key,
    required this.isDarkMode,
    required this.setDarkMode,
    required super.child,
  });

  final bool isDarkMode;
  final void Function(bool) setDarkMode;

  static AppThemeScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
  }

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) {
    return isDarkMode != oldWidget.isDarkMode;
  }
}
