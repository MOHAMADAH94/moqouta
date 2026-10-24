import 'package:flutter/material.dart';

/// ألوان موقوتا: أخضر داكن وذهبي، كما في التطبيق المثبّت.
class AppColors {
  static const Color background = Color(0xFF0A1C17);
  static const Color cardBackground = Color(0xFF112B24);
  static const Color cardBackgroundAlt = Color(0xFF173E33);
  static const Color borderDark = Color(0xFFD4AF37);
  static const Color divider = Color(0xFF1E3A30);
  static const Color navHighlight = Color(0xFFD4AF37);
  static const Color primary = Color(0xFFD4AF37);
  static const Color primarySoft = Color(0xFFC1A336);
  static const Color textPrimary = Color(0xFFF6F3EA);
  static const Color textSecondary = Color(0xFFB7C4BA);
  static const Color textMuted = Color(0xFF8FA396);
  static const Color surfaceLight = Color(0xFFF6F1E4);
  static const Color cardLight = Color(0xFFFFFCF6);
  static const Color borderLight = Color(0xFFE4D3A4);
  static const Color accent = Color(0xFFD4AF37);
  static const Color mint = Color(0xFF3FB58F);
}

@immutable
class MoqoutaColors extends ThemeExtension<MoqoutaColors> {
  const MoqoutaColors({
    required this.background,
    required this.card,
    required this.gold,
    required this.text,
    required this.muted,
    required this.mint,
    required this.line,
  });

  final Color background;
  final Color card;
  final Color gold;
  final Color text;
  final Color muted;
  final Color mint;
  final Color line;

  static const dark = MoqoutaColors(
    background: AppColors.background,
    card: AppColors.cardBackground,
    gold: AppColors.navHighlight,
    text: AppColors.textPrimary,
    muted: AppColors.textSecondary,
    mint: AppColors.mint,
    line: Color(0xFF1E3A30),
  );

  static const light = MoqoutaColors(
    background: Color(0xFFF4EFE2),
    card: Color(0xFFFFFCF6),
    gold: Color(0xFFA67C2D),
    text: Color(0xFF14261C),
    muted: Color(0xFF5C6D63),
    mint: Color(0xFF1F8F68),
    line: Color(0xFFE3D5B0),
  );

  @override
  MoqoutaColors copyWith({
    Color? background,
    Color? card,
    Color? gold,
    Color? text,
    Color? muted,
    Color? mint,
    Color? line,
  }) {
    return MoqoutaColors(
      background: background ?? this.background,
      card: card ?? this.card,
      gold: gold ?? this.gold,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      mint: mint ?? this.mint,
      line: line ?? this.line,
    );
  }

  @override
  MoqoutaColors lerp(ThemeExtension<MoqoutaColors>? other, double t) {
    if (other is! MoqoutaColors) return this;
    return MoqoutaColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      line: Color.lerp(line, other.line, t)!,
    );
  }
}

extension MoqoutaContext on BuildContext {
  MoqoutaColors get mq => Theme.of(this).extension<MoqoutaColors>() ?? MoqoutaColors.dark;
}

class AppTheme {
  static ThemeData get lightTheme => _theme(Brightness.light, MoqoutaColors.light);
  static ThemeData get darkTheme => _theme(Brightness.dark, MoqoutaColors.dark);

  static ThemeData _theme(Brightness brightness, MoqoutaColors colors) {
    final base = ThemeData(brightness: brightness, useMaterial3: true, fontFamily: 'Cairo');
    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.gold,
        onPrimary: colors.background,
        secondary: colors.mint,
        onSecondary: colors.background,
        error: const Color(0xFFE57373),
        onError: Colors.white,
        surface: colors.card,
        onSurface: colors.text,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colors.text,
        ),
      ),
      dividerColor: colors.line,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(colors.gold),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.mint;
          return const Color(0xFF1A3330);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      textTheme: base.textTheme.apply(fontFamily: 'Cairo', bodyColor: colors.text, displayColor: colors.text),
    );
  }
}
