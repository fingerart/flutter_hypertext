import 'package:flutter/rendering.dart';

const kDebugLogging = true;

final String? eof = null;

abstract final class Charcode {
  static const int nul = 0x00;

  /// '\t'
  static const int tab = 0x09;

  /// '\n'
  static const int lineFeed = 0x0A;
  static const int formFeed = 0x0C;

  /// '\r'
  static const int carriageReturn = 0x0D;

  /// ' '
  static const int space = 0x20;

  /// '"'
  static const int doubleQuote = 0x22;

  /// '&'
  static const int ampersand = 0x26;

  /// "'"
  static const int singleQuote = 0x27;

  /// '-'
  static const int hyphen = 0x2D;

  /// 0
  static const int zero = 0x30;

  /// '<'
  static const int lessThan = 0x3C;

  /// '='
  static const int equals = 0x3D;

  /// '>'
  static const int greaterThan = 0x3E;

  /// A
  static const int upperA = 0x41;

  /// Z
  static const int upperZ = 0x5A;

  /// '`'
  static const int graveAccent = 0x60;

  /// a
  static const int lowerA = 0x61;

  /// z
  static const int lowerZ = 0x7A;
}

const spaceCharacters = {
  Charcode.space,
  Charcode.lineFeed,
  Charcode.carriageReturn,
  Charcode.tab,
  Charcode.formFeed,
};

bool isWhitespace(String? char) {
  if (char == null) return false;
  return isWhitespaceCC(char.codeUnitAt(0));
}

bool isWhitespaceCC(int charCode) {
  switch (charCode) {
    case Charcode.tab:
    case Charcode.lineFeed:
    case Charcode.formFeed:
    case Charcode.carriageReturn:
    case Charcode.space:
      return true;
  }
  return false;
}

bool isLetter(String? char) {
  if (char == null) return false;
  final cc = char.codeUnitAt(0);
  return cc >= Charcode.lowerA && cc <= Charcode.lowerZ ||
      cc >= Charcode.upperA && cc <= Charcode.upperZ;
}

extension AsciiUpperToLower on String {
  /// Converts ASCII characters to lowercase.
  ///
  /// Unlike [String.toLowerCase] does not touch non-ASCII characters.
  String toAsciiLowerCase() {
    if (codeUnits.any(_isUpperCaseCode)) {
      return String.fromCharCodes(codeUnits.map(_asciiToLower));
    }
    return this;
  }

  static bool _isUpperCaseCode(int c) =>
      c >= Charcode.upperA && c <= Charcode.upperZ;

  static int _asciiToLower(int c) =>
      _isUpperCaseCode(c) ? c + Charcode.lowerA - Charcode.upperA : c;
}

const asciiCharacters = [
  '\u0000',
  '\u0001',
  '\u0002',
  '\u0003',
  '\u0004',
  '\u0005',
  '\u0006',
  '\u0007',
  '\u0008',
  '\u0009',
  '\u000a',
  '\u000b',
  '\u000c',
  '\u000d',
  '\u000e',
  '\u000f',
  '\u0010',
  '\u0011',
  '\u0012',
  '\u0013',
  '\u0014',
  '\u0015',
  '\u0016',
  '\u0017',
  '\u0018',
  '\u0019',
  '\u001a',
  '\u001b',
  '\u001c',
  '\u001d',
  '\u001e',
  '\u001f',
  '\u0020',
  '\u0021',
  '\u0022',
  '\u0023',
  '\u0024',
  '\u0025',
  '\u0026',
  '\u0027',
  '\u0028',
  '\u0029',
  '\u002a',
  '\u002b',
  '\u002c',
  '\u002d',
  '\u002e',
  '\u002f',
  '\u0030',
  '\u0031',
  '\u0032',
  '\u0033',
  '\u0034',
  '\u0035',
  '\u0036',
  '\u0037',
  '\u0038',
  '\u0039',
  '\u003a',
  '\u003b',
  '\u003c',
  '\u003d',
  '\u003e',
  '\u003f',
  '\u0040',
  '\u0041',
  '\u0042',
  '\u0043',
  '\u0044',
  '\u0045',
  '\u0046',
  '\u0047',
  '\u0048',
  '\u0049',
  '\u004a',
  '\u004b',
  '\u004c',
  '\u004d',
  '\u004e',
  '\u004f',
  '\u0050',
  '\u0051',
  '\u0052',
  '\u0053',
  '\u0054',
  '\u0055',
  '\u0056',
  '\u0057',
  '\u0058',
  '\u0059',
  '\u005a',
  '\u005b',
  '\u005c',
  '\u005d',
  '\u005e',
  '\u005f',
  '\u0060',
  '\u0061',
  '\u0062',
  '\u0063',
  '\u0064',
  '\u0065',
  '\u0066',
  '\u0067',
  '\u0068',
  '\u0069',
  '\u006a',
  '\u006b',
  '\u006c',
  '\u006d',
  '\u006e',
  '\u006f',
  '\u0070',
  '\u0071',
  '\u0072',
  '\u0073',
  '\u0074',
  '\u0075',
  '\u0076',
  '\u0077',
  '\u0078',
  '\u0079',
  '\u007a',
  '\u007b',
  '\u007c',
  '\u007d',
  '\u007e',
  '\u007f',
  '\u0080',
  '\u0081',
  '\u0082',
  '\u0083',
  '\u0084',
  '\u0085',
  '\u0086',
  '\u0087',
  '\u0088',
  '\u0089',
  '\u008a',
  '\u008b',
  '\u008c',
  '\u008d',
  '\u008e',
  '\u008f',
  '\u0090',
  '\u0091',
  '\u0092',
  '\u0093',
  '\u0094',
  '\u0095',
  '\u0096',
  '\u0097',
  '\u0098',
  '\u0099',
  '\u009a',
  '\u009b',
  '\u009c',
  '\u009d',
  '\u009e',
  '\u009f',
  '\u00a0',
  '\u00a1',
  '\u00a2',
  '\u00a3',
  '\u00a4',
  '\u00a5',
  '\u00a6',
  '\u00a7',
  '\u00a8',
  '\u00a9',
  '\u00aa',
  '\u00ab',
  '\u00ac',
  '\u00ad',
  '\u00ae',
  '\u00af',
  '\u00b0',
  '\u00b1',
  '\u00b2',
  '\u00b3',
  '\u00b4',
  '\u00b5',
  '\u00b6',
  '\u00b7',
  '\u00b8',
  '\u00b9',
  '\u00ba',
  '\u00bb',
  '\u00bc',
  '\u00bd',
  '\u00be',
  '\u00bf',
  '\u00c0',
  '\u00c1',
  '\u00c2',
  '\u00c3',
  '\u00c4',
  '\u00c5',
  '\u00c6',
  '\u00c7',
  '\u00c8',
  '\u00c9',
  '\u00ca',
  '\u00cb',
  '\u00cc',
  '\u00cd',
  '\u00ce',
  '\u00cf',
  '\u00d0',
  '\u00d1',
  '\u00d2',
  '\u00d3',
  '\u00d4',
  '\u00d5',
  '\u00d6',
  '\u00d7',
  '\u00d8',
  '\u00d9',
  '\u00da',
  '\u00db',
  '\u00dc',
  '\u00dd',
  '\u00de',
  '\u00df',
  '\u00e0',
  '\u00e1',
  '\u00e2',
  '\u00e3',
  '\u00e4',
  '\u00e5',
  '\u00e6',
  '\u00e7',
  '\u00e8',
  '\u00e9',
  '\u00ea',
  '\u00eb',
  '\u00ec',
  '\u00ed',
  '\u00ee',
  '\u00ef',
  '\u00f0',
  '\u00f1',
  '\u00f2',
  '\u00f3',
  '\u00f4',
  '\u00f5',
  '\u00f6',
  '\u00f7',
  '\u00f8',
  '\u00f9',
  '\u00fa',
  '\u00fb',
  '\u00fc',
  '\u00fd',
  '\u00fe',
  '\u00ff',
];

const mpBoxFit = {
  'fill': BoxFit.fill,
  'contain': BoxFit.contain,
  'cover': BoxFit.cover,
  'fitWidth': BoxFit.fitWidth,
  'fitHeight': BoxFit.fitHeight,
  'none': BoxFit.none,
  'scaleDown': BoxFit.scaleDown,
};
const mpAlignment = {
  'topLeft': Alignment.topLeft,
  'topCenter': Alignment.topCenter,
  'topRight': Alignment.topRight,
  'centerLeft': Alignment.centerLeft,
  'center': Alignment.center,
  'centerRight': Alignment.centerRight,
  'bottomLeft': Alignment.bottomLeft,
  'bottomCenter': Alignment.bottomCenter,
  'bottomRight': Alignment.bottomRight,
};
const mpPLAlignment = {
  'baseline': PlaceholderAlignment.baseline,
  'aboveBaseline': PlaceholderAlignment.aboveBaseline,
  'belowBaseline': PlaceholderAlignment.belowBaseline,
  'top': PlaceholderAlignment.top,
  'bottom': PlaceholderAlignment.bottom,
  'middle': PlaceholderAlignment.middle,
};
const mpBaselines = {
  'alphabetic': TextBaseline.alphabetic,
  'ideographic': TextBaseline.ideographic,
};
const mpTileMode = {
  'clamp': TileMode.clamp,
  'repeated': TileMode.repeated,
  'mirror': TileMode.mirror,
  'decal': TileMode.decal,
};
const mpMouseCursors = {
  'none': SystemMouseCursors.none,
  'basic': SystemMouseCursors.basic,
  'click': SystemMouseCursors.click,
  'forbidden': SystemMouseCursors.forbidden,
  'wait': SystemMouseCursors.wait,
  'progress': SystemMouseCursors.progress,
  'contextMenu': SystemMouseCursors.contextMenu,
  'help': SystemMouseCursors.help,
  'text': SystemMouseCursors.text,
  'verticalText': SystemMouseCursors.verticalText,
  'cell': SystemMouseCursors.cell,
  'precise': SystemMouseCursors.precise,
  'move': SystemMouseCursors.move,
  'grab': SystemMouseCursors.grab,
  'grabbing': SystemMouseCursors.grabbing,
  'noDrop': SystemMouseCursors.noDrop,
  'alias': SystemMouseCursors.alias,
  'copy': SystemMouseCursors.copy,
  'disappearing': SystemMouseCursors.disappearing,
  'allScroll': SystemMouseCursors.allScroll,
  'resizeLeftRight': SystemMouseCursors.resizeLeftRight,
  'resizeUpDown': SystemMouseCursors.resizeUpDown,
  'resizeUpLeftDownRight': SystemMouseCursors.resizeUpLeftDownRight,
  'resizeUpRightDownLeft': SystemMouseCursors.resizeUpRightDownLeft,
  'resizeUp': SystemMouseCursors.resizeUp,
  'resizeDown': SystemMouseCursors.resizeDown,
  'resizeLeft': SystemMouseCursors.resizeLeft,
  'resizeRight': SystemMouseCursors.resizeRight,
  'resizeUpLeft': SystemMouseCursors.resizeUpLeft,
  'resizeUpRight': SystemMouseCursors.resizeUpRight,
  'resizeDownLeft': SystemMouseCursors.resizeDownLeft,
  'resizeDownRight': SystemMouseCursors.resizeDownRight,
  'resizeColumn': SystemMouseCursors.resizeColumn,
  'resizeRow': SystemMouseCursors.resizeRow,
  'zoomIn': SystemMouseCursors.zoomIn,
  'zoomOut': SystemMouseCursors.zoomOut,
  'defer': MouseCursor.defer,
};
const mpTextDecorationStyle = {
  'double': TextDecorationStyle.double,
  'dashed': TextDecorationStyle.dashed,
  'dotted': TextDecorationStyle.dotted,
  'solid': TextDecorationStyle.solid,
  'wavy': TextDecorationStyle.wavy,
};
const mpTextDecoration = {
  'none': TextDecoration.none,
  'del': TextDecoration.lineThrough,
  'underline': TextDecoration.underline,
  'overline': TextDecoration.overline,
};

/// 电子邮箱模式
const emailPattern =
    r'([\w+-.%]+@[\w-.]+\.[A-Za-z]{2,4})((,[\w+-.%]+@[\w-.]+\.[A-Za-z]{2,4}){1,})?';

/// 提及用户
const mentionPattern = '@[a-z0-9_-]+';
