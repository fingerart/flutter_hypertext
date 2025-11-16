import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localization_intl_en.dart';
import 'localization_intl_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/localization_intl.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'<style size=30><gradient colors=\'appGreen,appOrange\' alignment=middle>Hypertext</gradient></style><gap=5 />is a rich text widget based on <img src=\'https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png\' height=30 width=102 /> with <padding hor=5><style color=appBlue decor=underline decor-color=labelTertiary decor-style=wavy>high extensibility</style></padding>.\n\n@hypertext #rich #text #rich-text #localization'**
  String get description;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'<color=labelSecondary>Common use cases:</color>\n1. Rich text with multilingual support<gap=10 /><style size=12 color=labelSecondary decor=underline><a href=\'fun://toggle-language-zh\' cursor=click title=\'Click to switch to Chinese\'>中文</a></style> | <style size=12 color=labelSecondary decor=underline><a href=\'fun://toggle-language-en\' cursor=click title=\'Click to switch to English\'>English</a></style>\n2. Rich text with different themes<gap=10 /><style size=12 color=labelSecondary decor=underline><a href=\'fun://toggle-theme-mode-dark\' cursor=click title=\'Click to switch to dark mode\'>Dark Mode</a></style> | <style size=12 color=labelSecondary decor=underline><a href=\'fun://toggle-theme-mode-light\' cursor=click title=\'Click to switch to light mode\'>Light Mode</a></style>\n3. Highlighting keywords\n<gap=20 />......'**
  String get cases;

  /// No description provided for @visitGitHub.
  ///
  /// In en, this message translates to:
  /// **'<img src=\'asset://assets/images/github-mark.png\' size=20 /> Click <a href=\'https://github.com/fingerart/flutter_hypertext\' cursor=click title=\'Open GitHub\'><text-decor underline>here</text-decor></a> to visit the <style background=labelTertiary> GitHub </style> repository'**
  String get visitGitHub;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'zh':
      return LZh();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
