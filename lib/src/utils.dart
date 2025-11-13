import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

extension IterableExtensions on Iterable? {
  bool get isEmpty => this == null || this!.isEmpty;

  bool get isNotEmpty => this != null && this!.isNotEmpty;
}

extension StringExtensions on String? {
  bool get isEmpty => this == null || this!.isEmpty;

  bool get isNotEmpty => this != null && this!.isNotEmpty;
}

extension MapExtensions on Map? {
  bool get isEmpty => this == null || this!.isEmpty;

  bool get isNotEmpty => this != null && this!.isNotEmpty;
}

extension MatchExtensions on Match {
  /// Returns the whole match String
  String get match => this[0]!;
}

extension InlineSpanExtensions on InlineSpan {
  bool dfvChildren(InlineSpanVisitor visitor) {
    final span = this;
    final List<InlineSpan>? children = span is TextSpan ? span.children : null;
    if (children != null) {
      for (final InlineSpan child in children) {
        if (!visitor(child)) {
          return false;
        }
        if (!child.dfvChildren(visitor)) return false;
      }
    }
    return true;
  }
}

double deg2rad(int deg) {
  return pi / 180 * (deg % 360);
}
