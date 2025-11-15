import 'dart:ui';

/// 颜色映射
typedef ColorMapper = Map<String, Color>;

/// Color的继承类
class Pigment extends Color {
  const Pigment(super.value);

  const Pigment.fromRGBO(super.r, super.g, super.b, super.opacity)
      : super.fromRGBO();

  const Pigment.fromARGB(super.a, super.r, super.g, super.b) : super.fromARGB();

  /// 从字符串解析颜色
  static Color? fromString(String? cString, [ColorMapper? mapper]) {
    if (cString == null || cString.isEmpty) return null;
    Color? color;

    int? cInt = _parseHexRGBA(cString);
    /* ?? _parseRGB(cString) ?? _parseHls(cString)*/

    if (cInt != null) {
      color = Pigment(cInt);
    } else if (mapper != null) {
      color = mapper[cString];
    }

    return color;
  }

  /// 解析16进制颜色
  ///
  /// #RGB       The three-value syntax
  /// #RGBA      The four-value syntax
  /// #RRGGBB    The six-value syntax
  /// #RRGGBBAA  The eight-value syntax
  static int? _parseHexRGBA(String color) {
    if (!RegExp(r'^#[0-9a-fA-F]{3,8}').hasMatch(color)) return null;

    color = color.substring(1);
    int size = color.length;
    // 无透明通道
    if (size == 6 || size == 3) {
      if (size == 3) {
        color = color[0] + color[0] + color[1] + color[1] + color[2] + color[2];
      }
      // Flutter的Color透明通道在前面
      color = 'FF$color';

      return int.tryParse(color, radix: 16);
    }
    // 存在透明通道
    else if (size == 8 || size == 4) {
      if (size == 4) {
        // @formatter:off
        color = color[0] + color[0] + color[1] + color[1] + color[2] + color[2] + color[3] + color[3];
        // @formatter:on
      }
      String alpha = color.substring(6);
      // Flutter的Color透明通道在前面
      color = alpha + color.substring(0, 6);
      return int.tryParse(color, radix: 16);
    }
    return null;
  }
}

/// 基础的CSS颜色映射集合
/// https://www.w3.org/wiki/CSS/Properties/color/keywords
const ColorMapper kBasicCSSColors = {
  'black': Color(0xFF000000),
  'silver': Color(0xFFC0C0C0),
  'gray': Color(0xFF808080),
  'white': Color(0xFFFFFFFF),
  'maroon': Color(0xFF800000),
  'red': Color(0xFFFF0000),
  'purple': Color(0xFF800080),
  'fuchsia': Color(0xFFFF00FF),
  'green': Color(0xFF008000),
  'lime': Color(0xFF00FF00),
  'olive': Color(0xFF808000),
  'yellow': Color(0xFFFFFF00),
  'navy': Color(0xFF000080),
  'blue': Color(0xFF0000FF),
  'teal': Color(0xFF008080),
  'aqua': Color(0xFF00FFFF),
};
