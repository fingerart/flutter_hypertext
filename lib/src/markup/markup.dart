import 'package:flutter/foundation.dart';

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
    String pattern, {
    this.startCharacter,
    bool caseSensitive = true,
  }) : pattern = RegExp(pattern, caseSensitive: caseSensitive);

  /// 起始字符
  final String? startCharacter;

  /// 匹配模式
  final RegExp pattern;

  @override
  List<String> get tags => [''];
}
