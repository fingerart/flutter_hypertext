import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'utils.dart';

final kEmptyHypertextSpan = HypertextTextSpan();

mixin HypertextSpan on InlineSpan {
  TextStyle? _inheritedStyle;

  @override
  bool visitDirectChildren(InlineSpanVisitor visitor) {
    return super.visitDirectChildren(_proxyVisitor(visitor));
  }

  InlineSpanVisitor _proxyVisitor(InlineSpanVisitor origin) {
    final inheritedStyle = _inheritedStyle?.merge(style) ?? style;
    return (InlineSpan span) {
      // 把合并后的样式传递给孩子
      if (span is HypertextSpan) {
        span._inheritedStyle = inheritedStyle;
      }
      return origin(span);
    };
  }
}

/// 具有遗传样式特性的[TextSpan]
// ignore: must_be_immutable
class HypertextTextSpan extends TextSpan with HypertextSpan {
  HypertextTextSpan({
    super.text,
    super.children,
    super.style,
    super.recognizer,
    super.mouseCursor,
    super.onEnter,
    super.onExit,
    super.semanticsLabel,
    super.locale,
    super.spellOut,
  });
}

/// 具有遗传样式特性的[WidgetSpan]
// ignore: must_be_immutable
class HypertextWidgetSpan extends WidgetSpan with HypertextSpan {
  HypertextWidgetSpan({
    required super.child,
    super.alignment,
    super.baseline,
    super.style,
    this.enableInherit = true,
  });

  /// 是否启用样式的遗传
  final bool enableInherit;

  @override
  Widget get child {
    if (!enableInherit) return super.child;

    // 合并当前组件和遗传的一样，通过[DefaultTextStyle]延续后代[Text]样式
    final inheritedStyle = _inheritedStyle?.merge(style) ?? style;
    if (inheritedStyle != null) {
      return DefaultTextStyle.merge(child: super.child, style: inheritedStyle);
    }
    return super.child;
  }
}

// ignore: unused_element
mixin _MultipleRecognizerMixin on HitTestTarget {
  List<GestureRecognizer>? get recognizers;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerDownEvent) {
      if (recognizers.isNotEmpty) {
        for (var recognizer in recognizers!) {
          recognizer.addPointer(event);
        }
      }
    }
  }
}
