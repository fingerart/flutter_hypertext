import 'dart:collection';

import '../constants.dart';
import '../tokenization/source_stream.dart';
import 'token.dart';

/// 分词状态
typedef State = bool Function();

/// 分词器
final class HypertextTokenizer with SourceMixin implements Iterator<Token> {
  HypertextTokenizer(
    String source, {
    this.lowercaseAttrName = true,
    this.lowercaseElementName = true,
  }) : source = SourceStream(source) {
    reset();
  }

  /// 源内容流
  @override
  final SourceStream source;

  /// 是否属性名称为小写
  final bool lowercaseAttrName;

  /// 是否限制元素名称为小写
  final bool lowercaseElementName;

  /// 分词单元队列
  final _tokenQueue = Queue<Token?>();

  final _buffer = StringBuffer();

  late State _state;

  /// 当前内部正在处理的[Token]
  Token? _curToken;

  TagToken get _curTagToken => _curToken as TagToken;

  /// 当前属性对象列表
  List<TagAttribute>? _attributes;
  Set<String>? _attributeNames;

  /// 当前正在处理的属性名称字符串缓冲器
  final _attributeName = StringBuffer();

  /// 当前正在处理的属性值字符串缓冲器
  final _attributeValue = StringBuffer();

  /// 当前向外部公开的词法单元
  Token? _current;

  @override
  Token get current => _current!;

  @override
  bool moveNext() {
    while (source.errors.isEmpty && _tokenQueue.isEmpty) {
      if (!_state()) {
        _current = null;
        return false;
      }
    }

    if (source.errors.isNotEmpty) {
      _current = ParseErrorToken(source.errors.removeFirst());
    } else {
      assert(_tokenQueue.isNotEmpty);
      _current = _tokenQueue.removeFirst();
    }
    return true;
  }

  void reset() {
    _attributes = null;
    _curToken = null;
    _current = null;
    _buffer.clear();
    _tokenQueue.clear();
    _state = _topState;
  }

  /// 添加[Token]到队列
  void addToken(Token token) => _tokenQueue.add(token);

  /// 顶层处理状态
  bool _topState() {
    final c = char();
    if (c == eof) {
      return false;
    } else if (c == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      addToken(CharactersToken('\u0000'));
    } else if (c == '<') {
      _state = _tagOpenState;
    } else if (isWhitespace(c)) {
      addToken(SpaceCharactersToken('$c${charsUntilSpace(true)}'));
    } else {
      final chars = charsUntil2(Charcode.lessThan, Charcode.nul);
      addToken(CharactersToken('$c$chars'));
    }
    return true;
  }

  /// ...<_
  bool _tagOpenState() {
    final data = char();
    if (data == '/') {
      _state = _closeTagOpenState;
    } else if (isLetter(data)) {
      _curToken = StartTagToken(data!);
      _state = _tagNameState;
    } else if (data == '>') {
      addToken(ParseErrorToken('expected-tag-name-but-got-right-bracket'));
      addToken(CharactersToken('<>'));
      _state = _topState;
    } else {
      addToken(ParseErrorToken('expected-tag-name'));
      addToken(CharactersToken('<'));
      unget(data);
      _state = _topState;
    }
    return true;
  }

  /// <tag>...</_
  bool _closeTagOpenState() {
    final data = char();
    if (isLetter(data)) {
      _curToken = EndTagToken(data!);
      _state = _tagNameState;
    } else if (data == '>') {
      addToken(ParseErrorToken('expected-closing-tag-but-got-right-bracket'));
      _state = _topState;
    } else if (data == eof) {
      addToken(ParseErrorToken('expected-closing-tag-but-got-eof'));
      addToken(CharactersToken('</'));
      _state = _topState;
    } else {
      addToken(ParseErrorToken('expected-closing-tag-but-got-char',
          messageParams: {'data': data}));
      _state = _topState;
    }
    return true;
  }

  /// <_ or </_
  bool _tagNameState() {
    final data = char();
    if (isWhitespace(data)) {
      _state = _beforeAttributeNameState;
    } else if (data == '=') {
      _addAttribute(_curTagToken.name);
      unget(data);
      _state = _attributeNameState;
    } else if (data == '>') {
      _emitCurrentToken();
    } else if (data == eof) {
      addToken(ParseErrorToken('eof-in-tag-name'));
      _state = _topState;
    } else if (data == '/') {
      _state = _selfClosingStartTagState;
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _curTagToken.name = '${_curTagToken.name}\uFFFD';
    } else {
      _curTagToken.name = '${_curTagToken.name}$data';
      // (Don't use charsUntil here, because tag names are
      // very short and it's faster to not do anything fancy)
    }
    return true;
  }

  /// <tag ... /_
  bool _selfClosingStartTagState() {
    final data = char();
    if (data == '>') {
      _curTagToken.selfClosing = true;
      _emitCurrentToken();
    } else if (data == eof) {
      addToken(ParseErrorToken('unexpected-EOF-after-solidus-in-tag'));
      unget(data);
      _state = _topState;
    } else {
      addToken(ParseErrorToken('unexpected-character-after-soldius-in-tag'));
      unget(data);
      _state = _beforeAttributeNameState;
    }
    return true;
  }

  /// <tag name=foo _
  bool _beforeAttributeNameState() {
    final data = char();
    if (isWhitespace(data)) {
      charsUntilSpace(true);
    } else if (data != null && isLetter(data)) {
      _addAttribute(data);
      _state = _attributeNameState;
    } else if (data == '>') {
      _emitCurrentToken();
    } else if (data == '/') {
      _state = _selfClosingStartTagState;
    } else if (data == eof) {
      addToken(ParseErrorToken('expected-attribute-name-but-got-eof'));
      _state = _topState;
    } else if ("'\"=<".contains(data!)) {
      addToken(ParseErrorToken('invalid-character-in-attribute-name'));
      _addAttribute(data);
      _state = _attributeNameState;
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _addAttribute('\uFFFD');
      _state = _attributeNameState;
    } else {
      _addAttribute(data);
      _state = _attributeNameState;
    }
    return true;
  }

  /// <tag name_
  bool _attributeNameState() {
    final data = char();
    var leavingThisState = true;
    var emitToken = false;
    if (data == '=') {
      _state = _beforeAttributeValueState;
    } else if (isLetter(data)) {
      _attributeName.write(data);
      _attributeName.write(charsUntilAsciiLetter(true));
      leavingThisState = false;
    } else if (data == '>') {
      // XXX If we emit here the attributes are converted to a dict
      // without being checked and when the code below runs we error
      // because data is a dict not a list
      emitToken = true;
    } else if (isWhitespace(data)) {
      _state = _afterAttributeNameState;
    } else if (data == '/') {
      _state = _selfClosingStartTagState;
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _attributeName.write('\uFFFD');
      leavingThisState = false;
    } else if (data == eof) {
      addToken(ParseErrorToken('eof-in-attribute-name'));
      _state = _topState;
    } else if ("'\"<".contains(data!)) {
      addToken(ParseErrorToken('invalid-character-in-attribute-name'));
      _attributeName.write(data);
      leavingThisState = false;
    } else {
      _attributeName.write(data);
      leavingThisState = false;
    }

    if (leavingThisState) {
      _markAttributeNameEnd(-1);

      // Attributes are not dropped at this stage. That happens when the
      // start tag token is emitted so values can still be safely appended
      // to attributes, but we do want to report the parse error in time.
      var attrName = _attributeName.toString();
      if (lowercaseAttrName) {
        attrName = attrName.toAsciiLowerCase();
      }
      _attributes!.last.name = attrName;
      _attributeNames ??= {};
      if (_attributeNames!.contains(attrName)) {
        addToken(ParseErrorToken('duplicate-attribute'));
      }
      _attributeNames!.add(attrName);

      // XXX Fix for above XXX
      if (emitToken) {
        _emitCurrentToken();
      }
    }
    return true;
  }

  /// <tag name _
  bool _afterAttributeNameState() {
    final data = char();
    if (isWhitespace(data)) {
      charsUntilSpace(true);
    } else if (data == '=') {
      _state = _beforeAttributeValueState;
    } else if (data == '>') {
      _emitCurrentToken();
    } else if (data != null && isLetter(data)) {
      _addAttribute(data);
      _state = _attributeNameState;
    } else if (data == '/') {
      _state = _selfClosingStartTagState;
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _addAttribute('\uFFFD');
      _state = _attributeNameState;
    } else if (data == eof) {
      addToken(ParseErrorToken('expected-end-of-tag-but-got-eof'));
      _state = _topState;
    } else if ("'\"<".contains(data!)) {
      addToken(ParseErrorToken('invalid-character-after-attribute-name'));
      _addAttribute(data);
      _state = _attributeNameState;
    } else {
      _addAttribute(data);
      _state = _attributeNameState;
    }
    return true;
  }

  /// <tag name=_
  bool _beforeAttributeValueState() {
    final data = char();
    if (isWhitespace(data)) {
      charsUntilSpace(true);
    } else if (data == '"') {
      _state = _attributeValueDoubleQuotedState;
    } else if (data == "'") {
      _state = _attributeValueSingleQuotedState;
    } else if (data == '>') {
      addToken(
          ParseErrorToken('expected-attribute-value-but-got-right-bracket'));
      _emitCurrentToken();
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _attributeValue.write('\uFFFD');
      _state = _attributeValueUnQuotedState;
    } else if (data == eof) {
      addToken(ParseErrorToken('expected-attribute-value-but-got-eof'));
      _state = _topState;
    } else if ('=<`'.contains(data!)) {
      addToken(ParseErrorToken('equals-in-unquoted-attribute-value'));
      _attributeValue.write(data);
      _state = _attributeValueUnQuotedState;
    } else {
      _attributeValue.write(data);
      _state = _attributeValueUnQuotedState;
    }
    return true;
  }

  /// <tag name="_ or <tag="_
  bool _attributeValueDoubleQuotedState() {
    final data = char();
    if (data == '"') {
      _markAttributeValueEnd(-1);
      _state = _afterAttributeValueState;
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _attributeValue.write('\uFFFD');
    } else if (data == eof) {
      addToken(ParseErrorToken('eof-in-attribute-value-double-quote'));
      _markAttributeValueEnd(-1);
      _state = _topState;
    } else {
      _attributeValue.write(data);
      _attributeValue
          .write(charsUntil2(Charcode.doubleQuote, Charcode.ampersand));
    }
    return true;
  }

  /// <tag name='_
  bool _attributeValueSingleQuotedState() {
    final data = char();
    if (data == "'") {
      _markAttributeValueEnd(-1);
      _state = _afterAttributeValueState;
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _attributeValue.write('\uFFFD');
    } else if (data == eof) {
      addToken(ParseErrorToken('eof-in-attribute-value-single-quote'));
      _markAttributeValueEnd(-1);
      _state = _topState;
    } else {
      _attributeValue.write(data);
      _attributeValue
          .write(charsUntil2(Charcode.singleQuote, Charcode.ampersand));
    }
    return true;
  }

  /// <tag name="..."_ or <tag name='...'_
  bool _afterAttributeValueState() {
    final data = char();
    if (isWhitespace(data)) {
      _state = _beforeAttributeNameState;
    } else if (data == '>') {
      _emitCurrentToken();
    } else if (data == '/') {
      _state = _selfClosingStartTagState;
    } else if (data == eof) {
      addToken(ParseErrorToken('unexpected-EOF-after-attribute-value'));
      unget(data);
      _state = _topState;
    } else {
      addToken(ParseErrorToken('unexpected-character-after-attribute-value'));
      unget(data);
      _state = _beforeAttributeNameState;
    }
    return true;
  }

  /// <tag name=_ or <tag=_
  bool _attributeValueUnQuotedState() {
    final data = char();
    if (isWhitespace(data)) {
      _markAttributeValueEnd(-1);
      _state = _beforeAttributeNameState;
    } else if (data == '>') {
      _markAttributeValueEnd(-1);
      _emitCurrentToken();
    } else if (data == eof) {
      addToken(ParseErrorToken('eof-in-attribute-value-no-quotes'));
      _markAttributeValueEnd(-1);
      _state = _topState;
    } else if ('"\'=<`'.contains(data!)) {
      addToken(
          ParseErrorToken('unexpected-character-in-unquoted-attribute-value'));
      _attributeValue.write(data);
    } else if (data == '\u0000') {
      addToken(ParseErrorToken('invalid-codepoint'));
      _attributeValue.write('\uFFFD');
    } else {
      _attributeValue.write(data);
      _attributeValue.write(charsUntil(const {
        Charcode.greaterThan,
        Charcode.doubleQuote,
        Charcode.singleQuote,
        Charcode.equals,
        Charcode.lessThan,
        Charcode.graveAccent,
        ...spaceCharacters
      }));
    }
    return true;
  }

  /// 结束[_curToken]的处理，将其添加到[_tokenQueue]中，以供外部使用
  /// 处理标签单元的属性、大小写等流程
  void _emitCurrentToken() {
    final token = _curToken!;
    if (token is TagToken) {
      if (lowercaseElementName) {
        token.name = token.name.toAsciiLowerCase();
      }
      if (token is EndTagToken) {
        if (_attributes != null) {
          addToken(ParseErrorToken('attributes-in-end-tag'));
        }
        if (token.selfClosing) {
          addToken(ParseErrorToken('this-closing-flag-on-end-tag'));
        }
      } else if (token is StartTagToken) {
        if (_attributes != null) {
          token.data = {};
          for (var attr in _attributes!) {
            token.data!.putIfAbsent(attr.name, () => attr.value); // 第一个属性有效
          }
        }
      }
      _attributes = null;
      _attributeNames = null;
    }
    addToken(token);
    _state = _topState;
  }

  void _addAttribute(String name) {
    _attributes ??= [];
    _attributeName.clear();
    _attributeName.write(name);
    _attributeValue.clear();
    _attributes!.add(TagAttribute());
  }

  void _markAttributeEnd(int offset) {
    _attributes!.last.value = _attributeValue.toString();
  }

  void _markAttributeValueEnd(int offset) {
    _markAttributeEnd(offset);
  }

  void _markAttributeNameEnd(int offset) => _markAttributeEnd(offset);
}
