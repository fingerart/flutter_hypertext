import 'package:flutter/material.dart';
import 'package:flutter_hypertext/hypertext.dart';
import 'package:flutter_hypertext/markup.dart';
import 'package:flutter_hypertext_example/settings.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'l10n/localization_intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 30,
          children: [
            Hypertext(
              L.of(context).description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
              onMarkupEvent: _onMarkupEvent,
            ),
            Hypertext(L.of(context).cases, onMarkupEvent: _onMarkupEvent),
            Hypertext(L.of(context).visitGitHub, onMarkupEvent: _onMarkupEvent),
          ],
        ),
      ),
    );
  }

  void _onMarkupEvent(MarkupEvent event) {
    switch (event.tag) {
      case 'a':
        var url = event.asData<Map<String, String>>()['href'];
        if (url?.startsWith(RegExp('https?://')) == true) {
          launchUrlString(url!);
        } else if (url?.startsWith('fun://') == true) {
          switch (url!.substring(6)) {
            case 'toggle-language-zh':
              settings.toggleChinese();
              break;
            case 'toggle-language-en':
              settings.toggleEnglish();
              break;
            case 'toggle-theme-mode-dark':
              settings.toggleTheme(ThemeMode.dark);
              break;
            case 'toggle-theme-mode-light':
              settings.toggleTheme(ThemeMode.light);
              break;
          }
        } else if (url?.startsWith('route://') == true) {}
        break;
    }
  }
}
