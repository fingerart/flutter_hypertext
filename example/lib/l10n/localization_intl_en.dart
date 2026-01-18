// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localization_intl.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get description =>
      '<style size=30><gradient colors=\'appGreen,appOrange\' alignment=middle>Hypertext</gradient></style><gap=5 />is a rich text widget based on <img src=\'https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png\' height=30 width=102 /> with <padding hor=5><style color=appBlue decor=underline decor-color=labelTertiary decor-style=wavy>high extensibility</style></padding>.\n\n@hypertext #rich #text #rich-text #localization';

  @override
  String get cases =>
      '<color=labelSecondary>Common use cases:</color>\n1. Rich text with multilingual support<gap=10 /><style name=hyperlink><a href=\'fun://toggle-language-zh\' cursor=click title=\'Click to switch to Chinese\'>中文</a></style> | <style name=hyperlink><a href=\'fun://toggle-language-en\' cursor=click title=\'Click to switch to English\'>English</a></style>\n2. Rich text with different themes<gap=10 /><style name=hyperlink><a href=\'fun://toggle-theme-mode-dark\' cursor=click title=\'Click to switch to dark mode\'>Dark Mode</a></style> | <style name=hyperlink><a href=\'fun://toggle-theme-mode-light\' cursor=click title=\'Click to switch to light mode\'>Light Mode</a></style>\n3. Highlighting keywords\n<gap=20 />......';

  @override
  String get visitGitHub =>
      '<img src=\'asset://assets/images/github-mark.png\' size=20 /> Click <a href=\'https://github.com/fingerart/flutter_hypertext\' cursor=click title=\'Open GitHub\'><text-decor underline>here</text-decor></a> to visit the <style background=labelTertiary> GitHub </style> repository';

  @override
  String get clickCopy => 'Click to copy';
}
