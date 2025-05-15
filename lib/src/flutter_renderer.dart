import 'package:flutter/material.dart';

import 'color.dart';
import 'markup/event.dart';
import 'markup/markup.dart';
import 'markup/similar_html_markup.dart';
import 'markup/specific_markup.dart';
import 'parser.dart';
import 'span.dart';
import 'utils.dart';

/// Event handler
typedef HypertextEventHandler = void Function(MarkupEvent event);

/// Built-in markups by default
const kDefaultMarkups = [
  LinkMarkup(),
  StyleMarkup(),
  FontWeightMarkup(),
  BoldMarkup(),
  FontStyleMarkup(),
  ItalicMarkup(),
  TextDecorationMarkup(),
  DelMarkup(),
  UnderlineMarkup(),
  ColorMarkup(),
  SizeMarkup(),
  GradientMarkup(),
  ImageMarkup(),
  GapMarkup(),
  PaddingMarkup(),
];

/// Text components with automatic parsing styles
class Hypertext extends StatefulWidget {
  const Hypertext(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.onMarkupEvent,
    this.lowercaseAttrName,
    this.lowercaseElementName,
    this.ignoreErrorMarkup,
    this.colorMapper,
    this.markups,
  });

  /// The text to display.
  final String text;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [data] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool? softWrap;

  /// How visual overflow should be handled.
  ///
  /// If this is null [TextStyle.overflow] will be used, otherwise the value
  /// from the nearest [DefaultTextStyle] ancestor will be used.
  final TextOverflow? overflow;

  /// {@macro flutter.painting.textPainter.textScaler}
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  final int? maxLines;

  /// {@template flutter.widgets.Text.semanticsLabel}
  /// An alternative semantics label for this text.
  ///
  /// If present, the semantics of this widget will contain this value instead
  /// of the actual text. This will overwrite any of the semantics labels applied
  /// directly to the [TextSpan]s.
  ///
  /// This is useful for replacing abbreviations or shorthands with the full
  /// text value:
  ///
  /// ```dart
  /// const Text(r'$$', semanticsLabel: 'Double dollars')
  /// ```
  /// {@endtemplate}
  final String? semanticsLabel;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro dart.ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// The color to use when painting the selection.
  ///
  /// This is ignored if [SelectionContainer.maybeOf] returns null
  /// in the [BuildContext] of the [Text] widget.
  ///
  /// If null, the ambient [DefaultSelectionStyle] is used (if any); failing
  /// that, the selection color defaults to [DefaultSelectionStyle.defaultColor]
  /// (semi-transparent grey).
  final Color? selectionColor;

  /// Whether to cast the attribute name in the parse marker to lowercase.
  /// Can be configured globally via [HypertextThemeExtension].
  final bool? lowercaseAttrName;

  /// Whether to cast the element name in the parse marker to lowercase.
  /// Can be configured globally via [HypertextThemeExtension].
  final bool? lowercaseElementName;

  /// 颜色名称映射，默认[kBasicCSSColors]
  final ColorMapper? colorMapper;

  /// Whether to block unresolved tags
  final bool? ignoreErrorMarkup;

  /// The markup event callback.
  /// Used to handle clicks, long presses, pointer levitation and other events.
  final HypertextEventHandler? onMarkupEvent;

  /// 定义超文本标记
  ///
  /// 通过此处的设置会覆盖掉[HypertextThemeExtension]中相同[HyperMarkup.tags]的标记
  final List<HyperMarkup>? markups;

  @override
  State<Hypertext> createState() => _HypertextState();
}

class _HypertextState extends State<Hypertext> {
  HypertextParser? _parser;

  /// The generated [InlineSpan] tree root node.
  List<HypertextSpan>? _children;

  /// Hypertext's theme extension.
  HypertextThemeExtension? _themeExt;

  Map<String, HyperMarkup>? _markups;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final oldThemeExt = _themeExt;
    _themeExt = Theme.of(context).extension();
    if (_themeExt != oldThemeExt || _parser == null) {
      _updateMarkups();
      _updateParser();
    }
  }

  @override
  void didUpdateWidget(covariant Hypertext oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.markups != oldWidget.markups) {
      _updateMarkups();
    }
    if (widget.text != oldWidget.text ||
        widget.markups != oldWidget.markups ||
        widget.lowercaseAttrName != oldWidget.lowercaseAttrName ||
        widget.lowercaseElementName != oldWidget.lowercaseElementName ||
        widget.colorMapper != oldWidget.colorMapper ||
        widget.ignoreErrorMarkup != oldWidget.ignoreErrorMarkup) {
      _updateParser();
    }
  }

  @override
  Widget build(BuildContext ctx) {
    if (_children == null) {
      return Text(
        widget.text,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        locale: widget.locale,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaler: widget.textScaler,
        maxLines: widget.maxLines,
        semanticsLabel: widget.semanticsLabel,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        selectionColor: widget.selectionColor,
      );
    }

    // 将当前顶层样式通过[HypertextSpan]进行传递
    final inheritedStyle = DefaultTextStyle.of(ctx).style.merge(widget.style);

    return Text.rich(
      HypertextTextSpan(children: _children, style: inheritedStyle),
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }

  /// 更新所有的[HyperMarkup]
  void _updateMarkups() {
    final markups = <String, HyperMarkup>{};

    final themeMarkups = _themeExt?.markups;
    if (themeMarkups.isEmpty && widget.markups.isEmpty) {
      for (var m in kDefaultMarkups) {
        for (var tag in m.tags) {
          markups[tag] = m;
        }
      }
    }

    if (themeMarkups.isNotEmpty) {
      for (var m in themeMarkups!) {
        for (var tag in m.tags) {
          markups[tag] = m;
        }
      }
    }
    if (widget.markups.isNotEmpty) {
      for (var m in widget.markups!) {
        for (var tag in m.tags) {
          markups[tag] = m;
        }
      }
    }
    _markups = markups;
  }

  /// Update parser and rebuild [InlineSpan] tree.
  void _updateParser() {
    _children = null;
    if (_markups?.isNotEmpty != true) {
      return; // 未定义任何标记，不需要任何解析操作
    }

    final lowAttrName =
        widget.lowercaseAttrName ?? _themeExt?.lowercaseAttrName;
    final lowEleName =
        widget.lowercaseElementName ?? _themeExt?.lowercaseElementName;
    final ignoreErrorMarkup =
        widget.ignoreErrorMarkup ?? _themeExt?.ignoreErrorMarkup;
    final colorMapper = widget.colorMapper ?? _themeExt?.colorMapper;

    _parser = HypertextParser(
      widget.text,
      markups: _markups!,
      eventHandler: _proxyEventHandler,
      lowercaseAttrName: lowAttrName,
      lowercaseElementName: lowEleName,
      ignoreErrorMarkup: ignoreErrorMarkup,
      colorMapper: colorMapper,
    );
    _children = _parser!.parse();
  }

  void _proxyEventHandler(MarkupEvent event) {
    widget.onMarkupEvent?.call(event);
  }
}

/// Extension for global configuration of Hypertext widget via topics
class HypertextThemeExtension extends ThemeExtension<HypertextThemeExtension> {
  const HypertextThemeExtension({
    this.lowercaseAttrName = true,
    this.lowercaseElementName = true,
    this.ignoreErrorMarkup = false,
    this.markups,
    this.colorMapper,
  });

  /// Whether to cast the attribute name in the parse marker to lowercase
  final bool lowercaseAttrName;

  /// Whether to cast the element name in the parse marker to lowercase
  final bool lowercaseElementName;

  /// Whether to block unresolved tags
  final bool ignoreErrorMarkup;

  final List<HyperMarkup>? markups;

  final ColorMapper? colorMapper;

  @override
  ThemeExtension<HypertextThemeExtension> copyWith({
    bool? lowercaseAttrName,
    bool? lowercaseElementName,
    bool? ignoreErrorMarkup,
    List<HyperMarkup>? markups,
    ColorMapper? colorMapper,
  }) {
    return HypertextThemeExtension(
      lowercaseAttrName: lowercaseAttrName ?? this.lowercaseAttrName,
      lowercaseElementName: lowercaseElementName ?? this.lowercaseElementName,
      ignoreErrorMarkup: ignoreErrorMarkup ?? this.ignoreErrorMarkup,
      markups: markups ?? this.markups,
      colorMapper: colorMapper ?? this.colorMapper,
    );
  }

  @override
  ThemeExtension<HypertextThemeExtension> lerp(
    covariant HypertextThemeExtension? other,
    double t,
  ) {
    return HypertextThemeExtension(
      lowercaseAttrName: other?.lowercaseAttrName ?? lowercaseAttrName,
      lowercaseElementName: other?.lowercaseElementName ?? lowercaseElementName,
      ignoreErrorMarkup: other?.ignoreErrorMarkup ?? ignoreErrorMarkup,
      markups: other?.markups ?? markups,
      colorMapper: other?.colorMapper ?? colorMapper,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HypertextThemeExtension &&
          runtimeType == other.runtimeType &&
          lowercaseAttrName == other.lowercaseAttrName &&
          lowercaseElementName == other.lowercaseElementName &&
          ignoreErrorMarkup == other.ignoreErrorMarkup &&
          markups == other.markups &&
          colorMapper == other.colorMapper;

  @override
  int get hashCode =>
      lowercaseAttrName.hashCode ^
      lowercaseElementName.hashCode ^
      ignoreErrorMarkup.hashCode ^
      markups.hashCode ^
      colorMapper.hashCode;
}
