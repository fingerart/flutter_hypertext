import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../color.dart';
import '../constants.dart';
import '../span.dart';
import '../utils.dart';
import 'context.dart';
import 'event.dart';
import 'markup.dart';

/// 定义链接标记
///
/// 有效的标签名称：[a]
/// 参数：
/// - href
/// - [tap|long-press]
/// - cursor: [click|defer]
/// - alignment: [PlaceholderAlignment]
/// - baseline: [alphabetic|ideographic] 参考[TextBaseline]
/// - your custom attr
///
/// 示例：`<a href="https://example.com" foo=bar>go</a>`
class LinkMarkup extends TagMarkup {
  const LinkMarkup({this.style, this.alignment, this.baseline}) : super('a');

  /// 默认的链接文本样式
  final TextStyle? style;

  /// How the placeholder aligns vertically with the text.
  ///
  /// See [ui.PlaceholderAlignment] for details on each mode.
  final PlaceholderAlignment? alignment;

  /// The [TextBaseline] to align against when using [ui.PlaceholderAlignment.baseline],
  /// [ui.PlaceholderAlignment.aboveBaseline], and [ui.PlaceholderAlignment.belowBaseline].
  ///
  /// This is ignored when using other alignment modes.
  final TextBaseline? baseline;

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    if (children.isEmpty) return kEmptyHypertextSpan;

    // 对于[children]只有一个[InheritedTextSpan]的情况，减少Widget嵌套将内容重新包装
    if (_canLift(children, ctx)) return _doLift(children!.first, ctx);

    final onLongPress = _enableLongPress(ctx)
        ? () => ctx.fireEvent(MarkupLongPressEvent.from(ctx))
        : null;
    final onTap = _enableTap(ctx) || onLongPress == null
        ? () => ctx.fireEvent(MarkupTapEvent.from(ctx))
        : null;
    final title = ctx.get('title');
    final cursor = _getCursor(ctx);
    final alignment = ctx.switchT(ctx.get('alignment'), mpPLAlignment);
    final baseline = ctx.switchT(ctx.get('baseline'), mpBaselines);

    final effectiveAlignment =
        alignment ?? this.alignment ?? PlaceholderAlignment.baseline;
    final effectiveBaseline = baseline ??
        this.baseline ??
        (this.alignment == null ? TextBaseline.alphabetic : null);

    Widget child = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Text.rich(HypertextTextSpan(children: children, style: style)),
    );
    if (title != null) {
      child = Tooltip(message: title, child: child);
    }
    if (cursor != null) {
      child = MouseRegion(cursor: cursor, child: child);
    }
    return HypertextWidgetSpan(
      alignment: effectiveAlignment,
      baseline: effectiveBaseline,
      child: child,
    );
  }

  HypertextTextSpan _doLift(HypertextSpan liftChild, MarkupContext context) {
    liftChild = liftChild as HypertextTextSpan;

    final cursor = _getCursor(context);
    final recognizer = _createRecognizer(context);

    return HypertextTextSpan(
      text: liftChild.text,
      style: liftChild.style?.merge(style) ?? style,
      mouseCursor: cursor,
      recognizer: recognizer,
    );
  }

  bool _canLift(List<HypertextSpan>? children, MarkupContext ctx) {
    final firstChild = children![0];
    return children.length == 1 &&
        firstChild is HypertextTextSpan &&
        firstChild.children.isEmpty &&
        !ctx.hasValue('title');
  }

  GestureRecognizer _createRecognizer(MarkupContext context) {
    if (_enableLongPress(context)) {
      return LongPressGestureRecognizer()
        ..onLongPress = () {
          context.fireEvent(MarkupLongPressEvent.from(context));
        };
    }

    // bool hasTap = _enableTap(context);
    return TapGestureRecognizer()
      ..onTap = () => context.fireEvent(MarkupTapEvent.from(context));

    // bool hasHover = context.attrs.containsKey('hover');
    // if (context.attrs.containsKey('event')) {}
  }

  MouseCursor? _getCursor(MarkupContext context) =>
      context.switchT(context.get('cursor'), mpMouseCursors) ??
      (kIsWeb ? SystemMouseCursors.click : null);

  bool _enableLongPress(MarkupContext context) => context.hasAttr('long-press');

  bool _enableTap(MarkupContext context) => context.hasAttr('tap');
}

typedef FontTextDecoration = ({
  TextDecoration? decoration,
  TextDecorationStyle? style,
  Color? color,
  double? thickness,
});

/// 文本样式的聚合标签
class StyleMarkup extends TagMarkup {
  const StyleMarkup({
    String tag = 'style',
    super.alias,
    this.colorMapper,
    this.weight,
    this.fontStyle,
    this.height,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
    this.decorationThickness,
  }) : super(tag);

  /// 字符串到[Color]的映射
  final ColorMapper? colorMapper;

  final FontWeight? weight;

  final FontStyle? fontStyle;
  final double? height;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    final color = optColor(ctx, enableTagAttr: false);
    final bgColor = optBgColor(ctx, enableTagAttr: false);
    final size = optFontSize(ctx, enableTagAttr: false);
    final font = optFontFamily(ctx, enableTagAttr: false);
    final fontWeight = optFontWeight(ctx, enableTagAttr: false);
    final fontStyle = optFontStyle(ctx, enableTagAttr: false);
    final height = ctx.getDouble('height');
    final decor = optTextDecoration(
      ctx,
      attrPrefix: 'decor-',
      enableTagAttr: false,
    );

    TextStyle? style;
    if (color != null ||
        bgColor != null ||
        size != null ||
        font != null ||
        fontWeight != null ||
        fontStyle != null ||
        height != null ||
        decor != null) {
      style = TextStyle(
        color: color,
        fontSize: size,
        fontFamily: font,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        backgroundColor: bgColor,
        decoration: decor?.decoration,
        decorationColor: decor?.color,
        decorationStyle: decor?.style,
        decorationThickness: decor?.thickness,
      );
    }

    return HypertextTextSpan(children: children, style: style);
  }

  @protected
  Color? optColor(MarkupContext context, {bool enableTagAttr = true}) {
    final colorMapper = this.colorMapper ?? context.colorMapper;
    if (enableTagAttr) {
      return context.getColorBy(
        tags,
        fallbackKey: 'color',
        colorMapper: colorMapper,
      );
    }
    return context.getColor('color', colorMapper);
  }

  @protected
  Color? optBgColor(MarkupContext context, {bool enableTagAttr = true}) {
    final colorMapper = this.colorMapper ?? context.colorMapper;
    if (enableTagAttr) {
      return context.getColorBy(
        tags,
        fallbackKey: 'background',
        colorMapper: colorMapper,
      );
    }
    return context.getColor('background', colorMapper);
  }

  @protected
  double? optFontSize(MarkupContext context, {bool enableTagAttr = true}) {
    if (enableTagAttr) {
      return context.getDoubleBy(tags, 'size');
    }
    return context.getDouble('size');
  }

  @protected
  String? optFontFamily(MarkupContext context, {bool enableTagAttr = true}) {
    if (enableTagAttr) {
      return context.getBy(tags, 'font-family');
    }
    return context.get('font-family');
  }

  @protected
  FontWeight? optFontWeight(
    MarkupContext ctx, {
    bool enableTagAttr = true,
  }) {
    FontWeight? weight = this.weight;

    int? w;
    if (enableTagAttr) {
      w = ctx.getIntBy(tags, 'weight');
    }
    w ??= ctx.getInt('weight');
    if (w != null) {
      weight = FontWeight.lerp(FontWeight.w100, FontWeight.w900, w / 900);
    }

    const weightAlias = {'bold': FontWeight.bold, 'normal': FontWeight.normal};
    weight ??= ctx.switchT(ctx.getBy(tags, 'weight'), weightAlias);

    return weight;
  }

  @protected
  FontStyle? optFontStyle(
    MarkupContext ctx, {
    bool enableTagAttr = true,
  }) {
    const params = {'normal': FontStyle.normal, 'italic': FontStyle.italic};
    FontStyle? fs;
    if (enableTagAttr) {
      fs ??= ctx.whenExist(params);
      fs ??= ctx.switchT(ctx.getBy(tags), params);
    }
    fs ??= ctx.switchT(ctx.get('font-style'), params);
    return fs ?? fontStyle;
  }

  @protected
  FontTextDecoration? optTextDecoration(
    MarkupContext ctx, {
    String attrPrefix = '',
    bool enableTagAttr = true,
  }) {
    // TODO: 支持TextDecoration.combine
    TextDecoration? decoration;
    if (enableTagAttr) {
      final decor = ctx.getBy(tags, 'decor');
      decoration ??= ctx.switchT(decor, mpTextDecoration) ??
          ctx.whenExist(mpTextDecoration);
    }
    decoration ??= ctx.switchT(ctx.get('decor'), mpTextDecoration);
    decoration ??= this.decoration;

    var style = ctx.switchT(
      ctx.get('${attrPrefix}style'),
      mpTextDecorationStyle,
    );
    style ??= decorationStyle;

    var color = Pigment.fromString(
      ctx.get('${attrPrefix}color'),
      ctx.colorMapper,
    );
    color ??= decorationColor;

    final thickness = ctx.getDouble('thickness') ?? decorationThickness;

    if (decoration == null &&
        style == null &&
        color == null &&
        thickness == null) {
      return null;
    }
    return (
      decoration: decoration,
      style: style,
      color: color,
      thickness: thickness,
    );
  }
}

/// 定义粗细标记
///
/// 接受粗细程度参数[weight]，与[FontWeight]的值保持一致，接受[FontWeight.w100]到
/// [FontWeight.w900]
///
/// 有效的Tag名称：[weight]
/// 参数：
/// - weight: [100-900|bold|normal]
///
/// 示例：
/// ```
/// <weight=700>bar</weight>
/// <weight weight=700>bar</weight>
/// ```
class FontWeightMarkup extends StyleMarkup {
  const FontWeightMarkup({super.tag = 'weight', super.alias, super.weight});

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    FontWeight? weight = optFontWeight(ctx);

    TextStyle? style;
    if (weight != null) style = TextStyle(fontWeight: weight);
    return HypertextTextSpan(children: children, style: style);
  }
}

/// 加粗标记
///
/// 有效的Tag名称：[b, bold]
///
/// 示例：
/// ```
/// <b>foo</b>
/// ```
class BoldMarkup extends FontWeightMarkup {
  const BoldMarkup()
      : super(
          tag: 'b',
          alias: const {'bold', 'strong'},
          weight: FontWeight.bold,
        );
}

/// 定义文本是否斜体标记
///
/// 有效的Tag名称：[font-style]
/// 参数：
/// - italic（无值）
/// - normal（无值）
///
/// 示例：
/// ```
/// <font-style italic>bar</font-style>
/// <font-style normal>bar</font-style>
/// ```
class FontStyleMarkup extends StyleMarkup {
  const FontStyleMarkup({
    super.tag = 'font-style',
    super.alias,
    super.fontStyle,
  });
}

/// 斜体样式标记
///
/// 有效的Tag名称：[i]
/// 参数：
/// - italic（默认，无值）
/// - normal（无值）
///
/// 示例：
/// ```
/// <i>bar</i>
/// <i normal>bar</i>
/// ```
class ItalicMarkup extends FontStyleMarkup {
  const ItalicMarkup() : super(tag: 'i', fontStyle: FontStyle.italic);
}

/// 文本装饰
///
/// 有效的Tag名称：[text-decor]
/// 参数：
/// - decor: [none|del|underline|overline] 参见[TextDecoration]
/// - style: [solid|double|dotted|dashed|wavy] 参见[TextDecorationStyle]
/// - color: [colorName|hexColor]
/// - thickness: double
///
/// 示例：
/// ```
/// <text-decor underline style=dotted>bar</text-decor>
/// <text-decor del color=red thickness=2>bar</text-decor>
/// ```
class TextDecorationMarkup extends StyleMarkup {
  const TextDecorationMarkup({
    super.tag = 'text-decor',
    super.alias,
    super.decoration,
    super.decorationStyle,
    super.decorationColor,
    super.decorationThickness,
  });

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    final decor = optTextDecoration(ctx);
    TextStyle? style;
    if (decor != null) {
      style = TextStyle(
        decorationStyle: decor.style,
        decoration: decor.decoration,
        decorationColor: decor.color,
        decorationThickness: decor.thickness,
      );
    }
    return HypertextTextSpan(children: children, style: style);
  }
}

/// 删除线
///
/// 有效的Tag名称：[del]
///
/// 示例：
/// ```
/// <del>foo</del>
/// ```
class DelMarkup extends TextDecorationMarkup {
  const DelMarkup({
    super.decorationStyle,
    super.decorationColor,
    super.decorationThickness,
  }) : super(tag: 'del', decoration: TextDecoration.lineThrough);
}

/// 下划线标记
///
/// 有效的Tag名称：[sub]
///
/// 示例：
/// ```
/// <u>foo</u>
/// <ins>foo</ins>
/// ```
class UnderlineMarkup extends TextDecorationMarkup {
  const UnderlineMarkup({
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
  }) : super(
          tag: 'u',
          alias: const {'ins'},
          decoration: TextDecoration.underline,
        );
}

/// 文本颜色标记
///
/// 对文本设置颜色，可通过[colorMapper]指定一组字符串到[Color]的映射， 默认映射是[kBasicCSSColors]
///
/// 有效的Tag名称：[color]
///
/// 参数
/// - color: [colorName|hexColor]
///
/// 示例：
/// ```
/// <color=red>foo</color>
/// <color color="#FF0000">foo</color>
/// ```
class ColorMarkup extends StyleMarkup {
  const ColorMarkup({super.tag = 'color', super.colorMapper});

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    final color = optColor(ctx);
    TextStyle? style = color != null ? TextStyle(color: color) : null;
    return HypertextTextSpan(children: children, style: style);
  }
}

/// 文本大小标记
///
/// 有效的Tag名称：[size]
///
/// 参数
/// - size: double
///
/// 示例：
/// ```
/// <size=18>foo</size>
/// <size size=20>foo</size>
/// ```
class SizeMarkup extends StyleMarkup {
  const SizeMarkup() : super(tag: 'size');

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    final size = optFontSize(ctx);
    TextStyle? style = size != null ? TextStyle(fontSize: size) : null;
    return HypertextTextSpan(children: children, style: style);
  }
}
