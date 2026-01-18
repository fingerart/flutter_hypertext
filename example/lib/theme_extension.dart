import 'package:flutter/material.dart';
import 'package:flutter_hypertext/hypertext.dart';
import 'package:flutter_hypertext/markup.dart';

extension ThemeDataExt on ThemeData {
  AppColorsExtension get appColors => extension<AppColorsExtension>()!;

  AppTextStylesExtension get appTextStyles =>
      extension<AppTextStylesExtension>()!;
}

extension ThemeGetterOnContext on BuildContext {
  AppColorsExtension get appColors => Theme.of(this).appColors;

  AppTextStylesExtension get appStyles => Theme.of(this).appTextStyles;
}

extension ThemeGetterOnState on State {
  AppColorsExtension get appColors => Theme.of(context).appColors;

  AppTextStylesExtension get appStyles => Theme.of(context).appTextStyles;
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>()!;
  }

  const AppColorsExtension({
    required this.appRed,
    required this.appOrange,
    required this.appYellow,
    required this.appGreen,
    required this.appBlue,
    required this.labelPrimary,
    required this.labelSecondary,
    required this.labelTertiary,
  });

  final Color appRed;
  final Color appOrange;
  final Color appYellow;
  final Color appGreen;
  final Color appBlue;
  final Color labelPrimary;
  final Color labelSecondary;
  final Color labelTertiary;

  ColorMapper toColorMapper() {
    return {
      ...kBasicCSSColors,
      'appRed': appRed,
      'appOrange': appOrange,
      'appYellow': appYellow,
      'appGreen': appGreen,
      'appBlue': appBlue,
      'labelPrimary': labelPrimary,
      'labelSecondary': labelSecondary,
      'labelTertiary': labelTertiary,
    };
  }

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? appRed,
    Color? appOrange,
    Color? appYellow,
    Color? appGreen,
    Color? appBlue,
    Color? labelPrimary,
    Color? labelSecondary,
    Color? labelTertiary,
  }) {
    return AppColorsExtension(
      appRed: appRed ?? this.appRed,
      appOrange: appOrange ?? this.appOrange,
      appYellow: appYellow ?? this.appYellow,
      appGreen: appGreen ?? this.appGreen,
      appBlue: appBlue ?? this.appBlue,
      labelPrimary: labelPrimary ?? this.labelPrimary,
      labelSecondary: labelSecondary ?? this.labelSecondary,
      labelTertiary: labelTertiary ?? this.labelTertiary,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      appRed: Color.lerp(appRed, other.appRed, t)!,
      appOrange: Color.lerp(appOrange, other.appOrange, t)!,
      appYellow: Color.lerp(appYellow, other.appYellow, t)!,
      appGreen: Color.lerp(appGreen, other.appGreen, t)!,
      appBlue: Color.lerp(appBlue, other.appBlue, t)!,
      labelPrimary: Color.lerp(labelPrimary, other.labelPrimary, t)!,
      labelSecondary: Color.lerp(labelSecondary, other.labelSecondary, t)!,
      labelTertiary: Color.lerp(labelTertiary, other.labelTertiary, t)!,
    );
  }

  ColorScheme toColorScheme(Brightness brightness) {
    throw UnimplementedError();
    // return ColorScheme(
    //   brightness: brightness,
    //   primary: primary,
    //   onPrimary: onPrimary,
    //   secondary: secondary,
    //   onSecondary: onSecondary,
    //   error: error,
    //   onError: onError,
    //   surface: background,
    //   onSurface: onBackground,
    // );
  }
}

class AppTextStylesExtension extends ThemeExtension<AppTextStylesExtension> {
  static AppTextStylesExtension of(BuildContext context) {
    return Theme.of(context).extension<AppTextStylesExtension>()!;
  }

  const AppTextStylesExtension({required this.hyperlink});

  final TextStyle hyperlink;

  StyleMapper toStyleMapper() {
    return {'hyperlink': hyperlink};
  }

  @override
  ThemeExtension<AppTextStylesExtension> copyWith({TextStyle? hyperlink}) {
    return AppTextStylesExtension(hyperlink: hyperlink ?? this.hyperlink);
  }

  @override
  ThemeExtension<AppTextStylesExtension> lerp(
    covariant ThemeExtension<AppTextStylesExtension>? other,
    double t,
  ) {
    if (other is! AppTextStylesExtension) {
      return this;
    }

    return AppTextStylesExtension(
      hyperlink: TextStyle.lerp(hyperlink, other.hyperlink, t)!,
    );
  }

  /// 将[AppTextStylesExtension]转换为[TextTheme]
  TextTheme toTextTheme() {
    throw UnimplementedError();
    // return TextTheme(
    //   displayLarge: headline1,
    //   displayMedium: headline3,
    //   displaySmall: headline5,
    //   headlineLarge: headline6,
    //   headlineMedium: headline7,
    //   headlineSmall: headline8,
    //   titleLarge: large$sb,
    //   titleMedium: medium$sb,
    //   titleSmall: small$sb,
    //   bodyLarge: large,
    //   bodyMedium: medium,
    //   bodySmall: small,
    //   labelLarge: large$m,
    //   labelMedium: medium$m,
    //   labelSmall: small$m,
    // );
  }
}
