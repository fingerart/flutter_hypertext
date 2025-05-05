import 'package:flutter_hypertext/src/tokenization/token.dart';
import 'package:flutter_hypertext/src/tokenization/tokenizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test tokenizer', () {
    final source =
        '<IMG src="https://example.com/avatar.png" alt="foo" />'
        'hello <b>world</b>,</b> I\'m <gradient> <sub>foo</sub></gradient>, my email'
        ' is <A href="mailto:foo@example.com">foo@example.com</A> '
        '<color=red>ok</color> <size=18 size=20>font size 18</size->';

    var tokenizer = HypertextTokenizer(source);
    var sb = StringBuffer();
    while (tokenizer.moveNext()) {
      var token = tokenizer.current;
      if (token is StartTagToken) {
        sb.write("<${token.name}");
        if (token.data != null && token.data!.isNotEmpty) {
          var attrs = token.data!.keys.map((e) => '$e="${token.data![e]}"');
          sb.write(" ");
          sb.writeAll(attrs, " ");
        }
        if (token.selfClosing) {
          sb.write(' /');
        }
        sb.write(">");
      } else if (token is EndTagToken) {
        sb.write("</${token.name}>");
      } else if (token is ParseErrorToken) {
        sb.write('~~${token.data}');
        if (token.messageParams != null) {
          sb.write('(${token.messageParams})');
        }
      } else if (token is StringToken) {
        sb.write(token.data);
      }
      sb.writeln();
    }
    print(sb);
  });
}
