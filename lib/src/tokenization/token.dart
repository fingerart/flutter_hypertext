/// 词法单元基类
abstract class Token {}

/// 标签词法单元
abstract class TagToken extends Token {
  /// 标签名称
  String name;

  /// 是否时自关闭标签（单标签）
  bool selfClosing;

  TagToken(this.name, {this.selfClosing = false});
}

/// 起始标签词法单元
class StartTagToken extends TagToken {
  StartTagToken(super.name, {this.data, super.selfClosing});

  /// 标签的属性列表
  Map<String, String>? data;

  String get rawTag {
    var sb = StringBuffer();
    sb.write('<');
    sb.write(name);
    data?.forEach((key, value) => sb.write(' $key="$value"'));
    sb.write('>');
    return sb.toString();
  }

  @override
  String toString() {
    return 'StartTagToken[$name]{data: $data}';
  }
}

/// 结束标签词法单元
class EndTagToken extends TagToken {
  EndTagToken(super.name, {super.selfClosing});
}

/// 字符串词法单元
abstract class StringToken extends Token {
  StringBuffer? _buffer;

  String? _string;

  String get data {
    if (_string == null) {
      _string = _buffer.toString();
      _buffer = null;
    }
    return _string!;
  }

  StringToken(this._string) : _buffer = _string == null ? StringBuffer() : null;

  StringToken add(String data) {
    _buffer!.write(data);
    return this;
  }
}

/// 解析错误词法单元
class ParseErrorToken extends StringToken {
  /// 与错误消息有关的额外信息
  Map<String, Object?>? messageParams;

  ParseErrorToken(String super.data, {this.messageParams});
}

/// 字符串词法单元
class CharactersToken extends StringToken {
  CharactersToken([super.data]);

  /// 替换字符串数据
  void replaceData(String newData) {
    _string = newData;
    _buffer = null;
  }
}

/// 空白字符串词法单元
/// 位于两个标签之间的空白，如：<foo> <bar>hello</bar></foo>
class SpaceCharactersToken extends StringToken {
  SpaceCharactersToken([super.data]);
}

/// 标签属性
class TagAttribute {
  TagAttribute({this.name = '', this.value = ''});

  String name;

  String value;
}
