import 'dart:io';

import 'package:flutter/widgets.dart';

/// 默认的内置图片构建器
/// 一般由外部提供，比如[NetworkImage]没有缓存功能
Widget? imageMarkupBuilder(
  BuildContext context,
  String uri, {
  double? width,
  double? height,
  Color? color,
  BoxFit? fit,
  Alignment? alignment,
}) {
  if (uri.startsWith(RegExp("https?://"))) {
    return Image.network(
      uri,
      width: width,
      height: height,
      color: color,
      alignment: alignment ?? Alignment.center,
      fit: fit,
    );
  }
  if (uri.startsWith("asset://")) {
    return Image.asset(
      uri.substring(8),
      width: width,
      height: height,
      color: color,
      alignment: alignment ?? Alignment.center,
      fit: fit,
    );
  }
  return Image.file(
    File(uri),
    width: width,
    height: height,
    color: color,
    alignment: alignment ?? Alignment.center,
    fit: fit,
  );
}
