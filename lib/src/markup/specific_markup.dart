import 'package:flutter/material.dart';

import '../../markup.dart';
import '../constants.dart';
import '../span.dart';
import '../utils.dart';
import '_markup_io.dart' if (dart.library.js_util) '_markup_web.dart';
import 'context.dart';
import 'markup.dart';

/// 文本渐变标记
///
/// 有效的Tag名称：[gradient]
/// 参数：
/// - gradient: [none|linear|radial|sweep] 参见[Gradient]
/// - colors: [colorName|hexColor]
/// - rotation: 角度值
/// - stops:
///
/// 示例：
/// ```
/// <gradient linear colors="red, blue" rotation=45>bar</gradient>
/// <gradient sweep colors="#FF0000, #0000FF" >bar</gradient>
/// ```
class GradientMarkup extends TagMarkup {
  const GradientMarkup({String tag = 'gradient', this.alignment, this.baseline})
      : super(tag);

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
    final colors = ctx.getColors('colors', colorMapper: ctx.colorMapper);
    if (colors == null) {
      return HypertextTextSpan(children: children);
    }

    assert(() {
      if (children != null) {
        bool styleColorChecker(InlineSpan s) {
          final existColor =
              s.style?.color != null && s.style?.color != Colors.white;
          if (existColor) {
            debugPrint(
              '[WARN] GradientMarkup: The color set by the children may cause '
              'the gradient to fail to take effect.',
            );
          }
          return !existColor;
        }

        TextSpan(children: children).dfvChildren(styleColorChecker);
      }
      return true;
    }());

    final stops = ctx.getDoubles('stops');
    final rotate = ctx.getInt('rotation');
    final tileMode = ctx.switchT(ctx.get('tile-mode'), mpTileMode);
    final alignment = ctx.switchT(ctx.get('alignment'), mpPLAlignment);
    final baseline = ctx.switchT(ctx.get('baseline'), mpBaselines);
    final transform = rotate != null ? GradientRotation(deg2rad(rotate)) : null;

    final effectiveAlignment =
        alignment ?? this.alignment ?? PlaceholderAlignment.baseline;
    final effectiveBaseline = baseline ??
        this.baseline ??
        (this.alignment == null ? TextBaseline.alphabetic : null);

    final gradient = LinearGradient(
      colors: colors,
      stops: stops,
      tileMode: tileMode ?? TileMode.clamp,
      transform: transform,
    );
    /* 需要显示设置为白色 */
    const textStyle = TextStyle(
      color: Colors.white,
      decorationColor: Colors.white,
    );
    return HypertextWidgetSpan(
      alignment: effectiveAlignment,
      baseline: effectiveBaseline,
      child: ShaderMask(
        shaderCallback: gradient.createShader,
        child: Text.rich(
          HypertextTextSpan(children: children, style: textStyle),
        ),
      ),
    );
  }
}

/// ImageMarkup的图片构建器
typedef ImageMarkupBuilder = Widget? Function(
  BuildContext context,
  String url, {
  double? width,
  double? height,
  BoxFit? fit,
  Alignment? alignment,
});

/// 图片标记
///
/// 有效的Tag名称：[img]
/// 参数：
/// - src: string, require
/// - width: double
/// - height: height
///
/// 示例：
/// ```
/// <img src="https://example.com/img.png" height=100 />
/// ```
class ImageMarkup extends TagMarkup {
  const ImageMarkup([
    this.alignment,
    this.baseline,
    this.imageBuilder = imageMarkupBuilder,
  ]) : super('img', alias: const {'image'});

  /// How the placeholder aligns vertically with the text.
  ///
  /// See [ui.PlaceholderAlignment] for details on each mode.
  final PlaceholderAlignment? alignment;

  /// The [TextBaseline] to align against when using [ui.PlaceholderAlignment.baseline],
  /// [ui.PlaceholderAlignment.aboveBaseline], and [ui.PlaceholderAlignment.belowBaseline].
  ///
  /// This is ignored when using other alignment modes.
  final TextBaseline? baseline;

  /// 图片构建器
  final ImageMarkupBuilder? imageBuilder;

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    final url = ctx.get('src');

    HypertextSpan? span;
    if (url.isNotEmpty) {
      double? width = ctx.getDouble('width');
      double? height = ctx.getDouble('height');
      if (width == null && height == null) {
        final s = ctx.getDoubles('size');
        if (s?.length == 1) {
          width = height = s![0];
        } else if (s?.length == 2) {
          width = s![0];
          height = s[1];
        }
      }
      final fit = ctx.switchT(ctx.get('fit'), mpBoxFit);
      final alignment = ctx.switchT(ctx.get('align'), mpAlignment);
      final plAlignment = ctx.switchT(ctx.get('alignment'), mpPLAlignment);
      final baseline = ctx.switchT(ctx.get('baseline'), mpBaselines);

      final effectiveAlignment =
          plAlignment ?? this.alignment ?? PlaceholderAlignment.middle;
      final effectiveBaseline = baseline ?? this.baseline;

      final builder = imageBuilder ?? imageMarkupBuilder;

      span = HypertextWidgetSpan(
        alignment: effectiveAlignment,
        baseline: effectiveBaseline,
        child: Builder(
          builder: (c) {
            return builder(
                  c,
                  url!,
                  width: width,
                  height: height,
                  fit: fit,
                  alignment: alignment,
                ) ??
                const SizedBox.shrink();
          },
        ),
      );
    }

    // 包装图片及其子元素到一个元素中
    if (children.isNotEmpty) {
      span = HypertextTextSpan(
        children: [if (span != null) span, ...?children],
      );
    }

    return span ?? kEmptyHypertextSpan;
  }
}

/// 间隙标记
///
/// 用于在文本见添加间隙
///
/// 有效tag名称：`gap`
/// 参数：
/// - gap [double]
class GapMarkup extends TagMarkup {
  const GapMarkup() : super('gap');

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext context) {
    if (kDebugLogging && children != null) {
      debugPrint(
        '[WARN] <gap/>: gap is a self-close tag, cannot display children.',
      );
    }
    final gap = context.getDouble(tag);
    return HypertextWidgetSpan(child: SizedBox(width: gap));
  }
}

/// 用于向内部填充间距
class PaddingMarkup extends TagMarkup {
  const PaddingMarkup([this.alignment, this.baseline]) : super('padding');

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
    final gaps = ctx.getDoubles(tag);
    EdgeInsets? padding = switch (gaps?.length) {
      1 => EdgeInsets.all(gaps![0]),
      2 => EdgeInsets.symmetric(vertical: gaps![0], horizontal: gaps[1]),
      3 => EdgeInsets.only(
          top: gaps![0],
          left: gaps[1],
          right: gaps[1],
          bottom: gaps[2],
        ),
      4 => EdgeInsets.only(
          left: gaps![0],
          top: gaps[1],
          right: gaps[2],
          bottom: gaps[3],
        ),
      _ => null,
    };

    final hor = ctx.getDoubles('hor');
    final ver = ctx.getDoubles('ver');
    if (padding == null && (hor.isNotEmpty || ver.isNotEmpty)) {
      var hors = switch (hor?.length) {
        1 => (hor![0], hor[0]),
        2 => (hor![0], hor[1]),
        _ => (0.0, 0.0),
      };
      var vers = switch (ver?.length) {
        1 => (ver![0], ver[0]),
        2 => (ver![0], ver[1]),
        _ => (0.0, 0.0),
      };

      padding = EdgeInsets.only(
        left: hors.$1,
        right: hors.$2,
        top: vers.$1,
        bottom: vers.$2,
      );
    }

    if (padding == null) return HypertextTextSpan(children: children);

    final alignment = ctx.switchT(ctx.get('alignment'), mpPLAlignment);
    final baseline = ctx.switchT(ctx.get('baseline'), mpBaselines);

    final effectiveAlignment =
        alignment ?? this.alignment ?? PlaceholderAlignment.baseline;
    final effectiveBaseline = baseline ??
        this.baseline ??
        (this.alignment == null ? TextBaseline.alphabetic : null);
    return HypertextWidgetSpan(
      alignment: effectiveAlignment,
      baseline: effectiveBaseline,
      child: Padding(
        padding: padding,
        child: Text.rich(HypertextTextSpan(children: children)),
      ),
    );
  }
}

/// 邮件地址标记
class EmailMarkup extends PatternMarkup {
  EmailMarkup(this.style, {String pattern = emailPattern, String tag = 'email'})
      : super(pattern, tag, caseSensitive: false);

  final TextStyle style;

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext context) {
    return HypertextTextSpan(children: children, style: style);
  }
}

/// 提及用户标记
class MentionMarkup extends PatternMarkup {
  MentionMarkup(
    this.style, {
    String pattern = mentionPattern,
    String tag = 'mention',
    this.enableLongPress = false,
    this.enableTap = true,
    this.alignment,
    this.baseline,
  }) : super(pattern, tag, startCharacter: Charcode.at, caseSensitive: false);

  final TextStyle style;

  /// How the placeholder aligns vertically with the text.
  ///
  /// See [ui.PlaceholderAlignment] for details on each mode.
  final PlaceholderAlignment? alignment;

  /// The [TextBaseline] to align against when using [ui.PlaceholderAlignment.baseline],
  /// [ui.PlaceholderAlignment.aboveBaseline], and [ui.PlaceholderAlignment.belowBaseline].
  ///
  /// This is ignored when using other alignment modes.
  final TextBaseline? baseline;

  final bool enableLongPress;
  final bool enableTap;

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    final onLongPress = enableLongPress
        ? () => ctx.fireEvent(MarkupLongPressEvent.from(ctx))
        : null;
    final onTap = enableTap || onLongPress == null
        ? () => ctx.fireEvent(MarkupTapEvent.from(ctx))
        : null;
    Widget child = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Text.rich(HypertextTextSpan(children: children, style: style)),
    );

    final effectiveAlignment = alignment ?? PlaceholderAlignment.baseline;
    final effectiveBaseline =
        baseline ?? (alignment == null ? TextBaseline.alphabetic : null);

    return HypertextWidgetSpan(
      alignment: effectiveAlignment,
      baseline: effectiveBaseline,
      child: child,
    );
  }
}
