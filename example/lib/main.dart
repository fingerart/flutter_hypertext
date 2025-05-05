import 'package:flutter/material.dart';
import 'package:flutter_hypertext_example/home_page.dart';
import 'package:flutter_hypertext_example/settings.dart';

import 'l10n/localization_intl.dart';

void main() {
  runApp(const HypertextApp());
}

class HypertextApp extends StatefulWidget {
  const HypertextApp({super.key});

  @override
  State<HypertextApp> createState() => _HypertextAppState();
}

class _HypertextAppState extends State<HypertextApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        return MaterialApp(
          themeMode: settings.themeMode,
          theme: settings.lightTheme,
          darkTheme: settings.darkTheme,
          locale: settings.local,
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: HomePage(),
        );
      },
    );
  }
}
