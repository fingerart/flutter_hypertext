import 'package:flutter/material.dart';
import 'package:flutter_hypertext/hypertext.dart';
import 'package:flutter_hypertext/markup.dart';

final settings = Settings();

class Settings with ChangeNotifier {
  Locale? _locale;

  Locale? get local => _locale;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  late final ThemeData lightTheme;
  late final ThemeData darkTheme;

  Settings() {
    const ColorMapper lightColors = {
      ...kBasicCSSColors,
      'appRed': Color(0xFFFF3B30),
      'appOrange': Color(0xFFFF9500),
      'appYellow': Color(0xFFFFCC00),
      'appGreen': Color(0xFF34C759),
      'appBlue': Color(0xFF007AFF),
      'labelPrimary': Color(0xFF000000),
      'labelSecondary': Color(0x993C3C43),
      'labelTertiary': Color(0x4C3C3C43),
    };
    const ColorMapper darkColors = {
      ...kBasicCSSColors,
      'appRed': Color(0xFFFF453A),
      'appOrange': Color(0xFFFF9F0A),
      'appYellow': Color(0xFFFFD60A),
      'appGreen': Color(0xFF30D158),
      'appBlue': Color(0xFF0A84FF),
      'labelPrimary': Color(0xFFFFFFFF),
      'labelSecondary': Color(0x99EBEBF5),
      'labelTertiary': Color(0x4CEBEBF5),
    };
    lightTheme = ThemeData.from(
      colorScheme: const ColorScheme.light(primary: Color(0xFF007AFF)),
    ).copyWith(
      extensions: const [
        HypertextThemeExtension(
          colorMapper: lightColors,
          markups: kDefaultMarkups,
        ),
      ],
    );
    darkTheme = ThemeData.from(
      colorScheme: const ColorScheme.dark(primary: Color(0xFF0A84FF)),
    ).copyWith(
      extensions: const [
        HypertextThemeExtension(
          colorMapper: darkColors,
          markups: kDefaultMarkups,
        ),
      ],
    );
  }

  void toggleChinese() {
    final l = const Locale('zh');
    if (_locale == l) return;

    _locale = l;
    notifyListeners();
  }

  void toggleEnglish() {
    final l = const Locale('en');
    if (_locale == l) return;

    _locale = l;
    notifyListeners();
  }

  void toggleTheme(ThemeMode mode) {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
  }
}
