import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late List<HyperMarkup> markups;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ext = HypertextThemeExtension.of(context);
    markups = [
      MentionMarkup(
        cursor: SystemMouseCursors.click,
        TextStyle(
          color: ext.colorMapper?['appOrange'],
          decoration: TextDecoration.underline,
          decorationColor: ext.colorMapper?['appOrange'],
        ),
      ),
      TopicMarkup(
        cursor: SystemMouseCursors.copy,
        tooltip: 'Click to copy',
        TextStyle(color: ext.colorMapper?['appGreen']),
      ),
    ];
  }

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
              markups: markups,
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
        final url = event.get<String>('href');
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
        }
      case 'mention':
        var mention = event[event.tag];
        print('mention: $mention');
        if (mention == '@hypertext') {
          launchUrlString('https://pub.dev/packages/flutter_hypertext');
        }
        break;
      case 'topic':
        final topic = event.require<String>(event.tag);
        Clipboard.setData(ClipboardData(text: topic));
        print('topic: $topic');
    }
  }
}
