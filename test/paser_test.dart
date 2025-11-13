import 'package:flutter/widgets.dart';
import 'package:flutter_hypertext/src/flutter_renderer.dart';
import 'package:flutter_hypertext/src/markup/specific_markup.dart';
import 'package:flutter_hypertext/src/parser.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test.dart';

void main() {
  final fullSource = openAsset('full.markups').readAsStringSync();
  final fullMatcher = openAsset('full.matcher').readAsStringSync();
  test('test full parse', () {
    final markups = [
      ...kDefaultMarkups,
      EmailMarkup(TextStyle()),
      MentionMarkup(TextStyle()),
    ];
    final parser = HypertextParser(fullSource, markups: markups);
    var b = DateTime.now().millisecondsSinceEpoch;
    parser.parse();
    print('took ${DateTime.now().millisecondsSinceEpoch - b}ms');
  });

  final escapeSource = openAsset('escape.markups').readAsStringSync();
  final escapeMatcher = openAsset('escape.matcher').readAsStringSync();
  test('test escape parse', () {
    final markups = kDefaultMarkups;
    final parser = HypertextParser(escapeSource, markups: markups);
    var b = DateTime.now().millisecondsSinceEpoch;
    parser.parse();
    print('took ${DateTime.now().millisecondsSinceEpoch - b}ms');
  });
}
