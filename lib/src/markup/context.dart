import 'dart:ui';

import '../color.dart';
import '../flutter_renderer.dart';
import '../utils.dart';
import 'event.dart';

/// [HyperMarkup]的上下文
class MarkupContext with _AttrsMixin {
  const MarkupContext(
    this.tag,
    Map<String, String>? attrs,
    this.isSelfClose,
    this._eventHandler,
    ColorMapper? colorMapper,
  )   : attrs = attrs ?? const {},
        colorMapper = colorMapper ?? kBasicCSSColors;

  final String tag;

  /// 标签上的属性
  @override
  final Map<String, String> attrs;

  /// 是否时自关闭标签
  final bool isSelfClose;

  final ColorMapper colorMapper;

  final HypertextEventHandler? _eventHandler;

  /// 向外部发送事件
  bool fireEvent(MarkupEvent event) {
    _eventHandler?.call(event);
    return _eventHandler != null;
  }
}

mixin _AttrsMixin {
  Map<String, String> get attrs;

  bool hasAttr(String key) => attrs.containsKey(key);

  bool hasValue(String key) => attrs[key].isNotEmpty;

  String require(String key, [String? fallbackKey]) => get(key, fallbackKey)!;

  String? get(String key, [String? fallbackKey]) {
    return attrs[key] ?? attrs[fallbackKey];
  }

  String? getBy(List<String> ks, [String? fallbackKey]) {
    for (var key in ks) {
      var value = attrs[key];
      if (value != null) return value;
    }
    if (fallbackKey != null) return attrs[fallbackKey];
    return null;
  }

  int? getInt(String key) {
    if (attrs[key].isEmpty) return null;
    return int.tryParse(attrs[key]!);
  }

  List<int>? getInts(String key, [String splitPatter = r'(\s*,+\s*)+']) {
    final raw = attrs[key];
    if (raw.isEmpty) return null;

    final rawInts = raw!.split(RegExp(splitPatter));
    if (rawInts.isEmpty) return null;
    if (rawInts.length == 1 && rawInts[0].isEmpty) return null;

    List<int>? ints;

    for (var rawInt in rawInts) {
      var i = int.tryParse(rawInt);
      if (i != null) {
        ints ??= [];
        ints.add(i);
      }
    }

    return ints;
  }

  int? getIntBy(List<String> ks, [String? fallbackKey]) {
    for (var key in ks) {
      var value = getInt(key);
      if (value != null) return value;
    }
    if (fallbackKey != null) return getInt(fallbackKey);
    return null;
  }

  double? getDouble(String key) {
    if (attrs[key].isEmpty) return null;
    return double.tryParse(attrs[key]!);
  }

  List<double>? getDoubles(String key, [String splitPatter = r'(\s*,+\s*)+']) {
    final raw = attrs[key];
    if (raw.isEmpty) return null;

    final rawDoubles = raw!.split(RegExp(splitPatter));
    if (rawDoubles.isEmpty) return null;
    if (rawDoubles.length == 1 && rawDoubles[0].isEmpty) return null;

    List<double>? ints;

    for (var rawDouble in rawDoubles) {
      var d = double.tryParse(rawDouble);
      if (d != null) {
        ints ??= [];
        ints.add(d);
      }
    }

    return ints;
  }

  double? getDoubleBy(List<String> ks, [String? fallbackKey]) {
    for (var key in ks) {
      var value = getDouble(key);
      if (value != null) return value;
    }
    if (fallbackKey != null) return getDouble(fallbackKey);
    return null;
  }

  Color? getColor(String key, [ColorMapper? colorMapper = kBasicCSSColors]) {
    if (attrs[key].isEmpty) return null;
    return Pigment.fromString(attrs[key], colorMapper);
  }

  List<Color>? getColors(
    String key, {
    String splitPatter = r'(\s*,+\s*)+',
    ColorMapper? colorMapper = kBasicCSSColors,
  }) {
    final raw = attrs[key];
    if (raw.isEmpty) return null;

    final rawColors = raw!.split(RegExp(splitPatter));
    if (rawColors.isEmpty) return null;
    if (rawColors.length == 1 && rawColors[0].isEmpty) return null;

    List<Color>? colors;

    for (var rawColor in rawColors) {
      var color = Pigment.fromString(rawColor, colorMapper);
      if (color != null) {
        colors ??= [];
        colors.add(color);
      }
    }

    return colors;
  }

  Color? getColorBy(
    List<String> ks, {
    String? fallbackKey,
    ColorMapper? colorMapper = kBasicCSSColors,
  }) {
    for (var key in ks) {
      var value = getColor(key, colorMapper);
      if (value != null) return value;
    }
    if (fallbackKey != null) return getColor(fallbackKey, colorMapper);
    return null;
  }

  /// 当某个Key存在
  T? whenExist<T>(Map<String, T?> m) {
    for (var k in m.keys) {
      if (hasAttr(k)) {
        return m[k]!;
      }
    }
    return null;
  }

  T? whenExist2<T>(Map<String, T? Function(String value)> m) {
    for (var k in m.keys) {
      if (hasAttr(k)) {
        return m[k]!.call(attrs[k]!);
      }
    }
    return null;
  }

  V? switchT<V, K>(K k, Map<K, V?> m) => m[k];

  T? switchT2<T, TT>(TT t, Map<TT, T? Function(TT value)> m) {
    return m[t]?.call(t);
  }
}
