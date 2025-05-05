import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// 节点数相等
NodeMatcher nodeTreeEquals(InlineSpan expected) => NodeMatcher(expected);

/// 节点相等匹配器
class NodeMatcher extends Matcher {
  const NodeMatcher(this._expected);

  final InlineSpan _expected;

  @override
  Description describe(Description description) {
    return description.add('equals ').addDescriptionOf(_expected);
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    throw UnimplementedError();
  }
}
