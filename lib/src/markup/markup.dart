import 'package:flutter/foundation.dart';
import 'package:flutter_hypertext/src/parser.dart';
import 'package:flutter_hypertext/src/utils.dart';

import '../color.dart';
import '../constants.dart';
import '../flutter_renderer.dart';
import '../span.dart';
import '../tokenization/token.dart';
import 'context.dart';

/// 定义标记的基类
abstract class HyperMarkup {
  const HyperMarkup();

  /// 支持的标签集合
  List<String> get tags;

  HypertextSpan markup(
    List<HypertextSpan>? children,
    StartTagToken token,
    HypertextEventHandler? eventHandler,
    ColorMapper? colorMapper,
  ) {
    final context = MarkupContext(
      token.name,
      token.data,
      token.selfClosing,
      eventHandler,
      colorMapper,
    );

    if (kDebugLogging) {
      debugPrint('markup:[${context.tag}] ${context.attrs}');
    }
    return onMarkup(children, context);
  }

  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext context);
}

/// 自定义标签标记
abstract class TagMarkup extends HyperMarkup {
  const TagMarkup(this.tag, {this.alias});

  /// 标签名称
  final String tag;

  /// 标签别名
  final Set<String>? alias;

  @override
  List<String> get tags => [tag, ...?alias];
}

/// 基于一个模式的标记
abstract class PatternMarkup extends HyperMarkup {
  PatternMarkup(
    String pattern,
    String tag, {
    this.startCharacter,
    bool caseSensitive = true,
  })  : tags = [tag],
        pattern = RegExp(pattern, caseSensitive: caseSensitive);

  /// 起始字符
  final int? startCharacter;

  /// 匹配模式
  final RegExp pattern;

  @override
  final List<String> tags;

  bool tryMatch(PatternParser parser, [int? startMatchPos]) {
    startMatchPos ??= parser.pos;

    if (startCharacter != null &&
        parser.charAt(startMatchPos) != startCharacter) {
      return false;
    }

    final startMatch = pattern.matchAsPrefix(parser.source, startMatchPos);
    if (startMatch == null) return false;

    parser.writeText();

    if (onMatch(parser, startMatch)) parser.consume(startMatch.match.length);
    return true;
  }

  bool onMatch(PatternParser parser, Match startMatch) {
    final tag = tags.first;
    final content = startMatch.match;
    final data = <String, String>{tag: content, 'value': content};
    parser.addToken(StartTagToken(tag, data: data));
    parser.addToken(CharactersToken(content));
    parser.addToken(EndTagToken(tag));
    return true;
  }
}
