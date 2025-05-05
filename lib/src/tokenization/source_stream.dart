import 'dart:collection';

import '../constants.dart';

abstract interface class Walker {
  String? char();

  int get position;

  String? peekChar();

  int? peekCodeUnit();

  String charsUntil(Set<int> charCodes, [bool opposite = false]);

  String charsUntil1(int charCode, [bool opposite = false]);

  String charsUntil2(int charCode1, int charCode2, [bool opposite = false]);

  String charsUntil3(
    int charCode1,
    int charCode2,
    int charCode3, [
    bool opposite = false,
  ]);

  String charsUntilAsciiLetter([bool opposite = false]);

  String charsUntilSpace([bool opposite = false]);

  void unget(String? ch);
}

mixin SourceMixin implements Walker {
  /// 源内容流
  Walker get source;

  @override
  String? char() => source.char();

  @override
  int get position => source.position;

  @override
  String? peekChar() => source.peekChar();

  @override
  int? peekCodeUnit() => source.peekCodeUnit();

  @override
  String charsUntil(Set<int> charCodes, [bool opposite = false]) =>
      source.charsUntil(charCodes, opposite);

  @override
  String charsUntil1(int charCode, [bool opposite = false]) =>
      source.charsUntil1(charCode, opposite);

  @override
  String charsUntil2(int charCode1, int charCode2, [bool opposite = false]) =>
      source.charsUntil2(charCode1, charCode2, opposite);

  @override
  String charsUntil3(
    int charCode1,
    int charCode2,
    int charCode3, [
    bool opposite = false,
  ]) =>
      source.charsUntil3(charCode1, charCode2, charCode3, opposite);

  @override
  String charsUntilAsciiLetter([bool opposite = false]) =>
      source.charsUntilAsciiLetter(opposite);

  @override
  String charsUntilSpace([bool opposite = false]) =>
      source.charsUntilSpace(opposite);

  @override
  void unget(String? ch) => source.unget(ch);
}

/// Provides a unicode stream of characters to the HtmlTokenizer.
///
/// This class takes care of character encoding and removing or replacing
/// incorrect byte-sequences and also provides column and line tracking.
class SourceStream implements Walker {
  /// Raw UTF-16 codes, used if a Dart String is passed in.
  final List<int> _rawChars;

  Queue<String> errors = Queue<String>();

  var _chars = <int>[];

  var _offset = 0;

  /// Initialise an HtmlInputStream.
  ///
  /// HtmlInputStream(source, [encoding]) -> Normalized stream from source
  /// for use by html5lib.
  ///
  /// [source] can be either a `String` or a `List<int>` containing the raw
  /// bytes.
  ///
  /// The optional encoding parameter must be a string that indicates
  /// the encoding.  If specified, that encoding will be used,
  /// regardless of any BOM or later declaration (such as in a meta
  /// element)
  ///
  /// [parseMeta] - Look for a <meta> element containing encoding information
  SourceStream(String source) : _rawChars = source.codeUnits {
    reset();
  }

  void reset() {
    errors = Queue<String>();

    _offset = 0;

    final rawChars = _rawChars;

    // Optimistically allocate array, trim it later if there are changes
    _chars = List.filled(rawChars.length, 0, growable: true);
    var skipNewline = false;
    var wasSurrogatePair = false;
    var deletedChars = 0;

    /// CodeUnits.length is not free
    final charsLength = rawChars.length;
    for (var i = 0; i < charsLength; i++) {
      var c = rawChars[i];
      if (skipNewline) {
        skipNewline = false;
        if (c == Charcode.lineFeed) {
          deletedChars++;
          continue;
        }
      }

      final isSurrogatePair = _isLeadSurrogate(c) &&
          i + 1 < charsLength &&
          _isTrailSurrogate(rawChars[i + 1]);
      if (!isSurrogatePair && !wasSurrogatePair) {
        if (_invalidUnicode(c)) {
          errors.add('invalid-codepoint');

          if (0xD800 <= c && c <= 0xDFFF) {
            c = 0xFFFD;
          }
        }
      }
      wasSurrogatePair = isSurrogatePair;

      if (c == Charcode.carriageReturn) {
        skipNewline = true;
        c = Charcode.lineFeed;
      }

      _chars[i - deletedChars] = c;
    }
    if (deletedChars > 0) {
      // Remove the null bytes from the end
      _chars.removeRange(_chars.length - deletedChars, _chars.length);
    }
  }

  /// Returns the current offset in the stream, i.e. the number of codepoints
  /// since the start of the file.
  @override
  int get position => _offset;

  /// Read one character from the stream or queue if available. Return
  /// EOF when EOF is reached.
  @override
  String? char() {
    if (_offset >= _chars.length) return eof;
    final firstCharCode = _chars[_offset++];
    if (firstCharCode < 256) {
      return asciiCharacters[firstCharCode];
    }
    if (_isSurrogatePair(_chars, _offset - 1)) {
      return String.fromCharCodes([firstCharCode, _chars[_offset++]]);
    }
    return String.fromCharCode(firstCharCode);
  }

  @override
  int? peekCodeUnit() {
    if (_offset >= _chars.length) return null;
    return _chars[_offset];
  }

  @override
  String? peekChar() {
    if (_offset >= _chars.length) return eof;
    final firstCharCode = _chars[_offset];
    if (firstCharCode < 256) {
      return asciiCharacters[firstCharCode];
    }
    if (_isSurrogatePair(_chars, _offset)) {
      return String.fromCharCodes([firstCharCode, _chars[_offset + 1]]);
    }
    return String.fromCharCode(firstCharCode);
  }

  /// Whether the current and next chars indicate a surrogate pair.
  bool _isSurrogatePair(List<int> chars, int i) {
    return i + 1 < chars.length &&
        _isLeadSurrogate(chars[i]) &&
        _isTrailSurrogate(chars[i + 1]);
  }

  /// Is then code (a 16-bit unsigned integer) a UTF-16 lead surrogate.
  bool _isLeadSurrogate(int code) => (code & 0xFC00) == 0xD800;

  /// Is then code (a 16-bit unsigned integer) a UTF-16 trail surrogate.
  bool _isTrailSurrogate(int code) => (code & 0xFC00) == 0xDC00;

  /// Returns a string of characters from the stream up to but not
  /// including any character in 'characters' or EOF. These functions rely
  /// on the charCode(s) being single-codepoint.
  @override
  String charsUntil(Set<int> charCodes, [bool opposite = false]) {
    final start = _offset;
    int? c;
    while ((c = peekCodeUnit()) != null && charCodes.contains(c!) == opposite) {
      _offset += 1;
    }

    return String.fromCharCodes(_chars.sublist(start, _offset));
  }

  @override
  String charsUntil1(int charCode, [bool opposite = false]) {
    final start = _offset;
    int? c;
    while ((c = peekCodeUnit()) != null && (charCode == c!) == opposite) {
      _offset += 1;
    }

    return String.fromCharCodes(_chars.sublist(start, _offset));
  }

  @override
  String charsUntil2(int charCode1, int charCode2, [bool opposite = false]) {
    final start = _offset;
    int? c;
    while ((c = peekCodeUnit()) != null &&
        (charCode1 == c! || charCode2 == c) == opposite) {
      _offset += 1;
    }

    return String.fromCharCodes(_chars.sublist(start, _offset));
  }

  @override
  String charsUntil3(int charCode1, int charCode2, int charCode3,
      [bool opposite = false]) {
    final start = _offset;
    int? c;
    while ((c = peekCodeUnit()) != null &&
        (charCode1 == c! || charCode2 == c || charCode3 == c) == opposite) {
      _offset += 1;
    }

    return String.fromCharCodes(_chars.sublist(start, _offset));
  }

  @override
  String charsUntilAsciiLetter([bool opposite = false]) {
    final start = _offset;
    int? c;
    while ((c = peekCodeUnit()) != null &&
        ((c! >= Charcode.upperA && c <= Charcode.upperZ) ||
                (c >= Charcode.lowerA && c <= Charcode.lowerZ)) ==
            opposite) {
      _offset += 1;
    }
    return String.fromCharCodes(_chars.sublist(start, _offset));
  }

  @override
  String charsUntilSpace([bool opposite = false]) {
    final start = _offset;
    int? c;
    while ((c = peekCodeUnit()) != null && isWhitespaceCC(c!) == opposite) {
      _offset += 1;
    }

    return String.fromCharCodes(_chars.sublist(start, _offset));
  }

  @override
  void unget(String? ch) {
    // Only one character is allowed to be ungotten at once - it must
    // be consumed again before any further call to unget
    if (ch != null) {
      _offset -= ch.length;
      assert(peekChar() == ch);
    }
  }
}

// Dart doesn't let you create a regexp with invalid characters.
bool _invalidUnicode(int c) {
  // Fast return for common ASCII characters
  if (0x0020 <= c && c <= 0x007E) return false;
  if (0x0001 <= c && c <= 0x0008) return true;
  if (0x000E <= c && c <= 0x001F) return true;
  if (0x007F <= c && c <= 0x009F) return true;
  if (0xD800 <= c && c <= 0xDFFF) return true;
  if (0xFDD0 <= c && c <= 0xFDEF) return true;
  switch (c) {
    case 0x000B:
    case 0xFFFE:
    case 0xFFFF:
    case 0x01FFFE:
    case 0x01FFFF:
    case 0x02FFFE:
    case 0x02FFFF:
    case 0x03FFFE:
    case 0x03FFFF:
    case 0x04FFFE:
    case 0x04FFFF:
    case 0x05FFFE:
    case 0x05FFFF:
    case 0x06FFFE:
    case 0x06FFFF:
    case 0x07FFFE:
    case 0x07FFFF:
    case 0x08FFFE:
    case 0x08FFFF:
    case 0x09FFFE:
    case 0x09FFFF:
    case 0x0AFFFE:
    case 0x0AFFFF:
    case 0x0BFFFE:
    case 0x0BFFFF:
    case 0x0CFFFE:
    case 0x0CFFFF:
    case 0x0DFFFE:
    case 0x0DFFFF:
    case 0x0EFFFE:
    case 0x0EFFFF:
    case 0x0FFFFE:
    case 0x0FFFFF:
    case 0x10FFFE:
    case 0x10FFFF:
      return true;
  }
  return false;
}
