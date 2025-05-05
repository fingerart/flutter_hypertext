import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test MLParser#parse', () {
    final source = '''
    <img src="https://example.com/avatar.png" alt="foo"/>hello <b>world</b>, I'm
     <gradient> <sub>foo</sub></gradient>, my email is <a href="mailto:foo@example.com">
    foo@example.com</a> 
    ''';
    // final expectNode = Element('root', [
    //   Element.empty('img')
    //     ..attributes.addAll({
    //       'src': 'https://example.com/avatar.png',
    //     }),
    //   Text('hello'),
    //   Element('b', [Text('world')]),
    //   Text(", I'm"),
    //   Element('gradient', [
    //     Text(' '),
    //     Element('sub', [Text('foo')])
    //   ]),
    //   Text(", my email is "),
    //   Element('a', [Text('foo@example.com')])
    //     ..attributes.addAll({'href': 'mailto:foo@example.com'}),
    // ]);
    // final doc = Document(source);
    // final rootNode = doc.parse();
    // expect(rootNode, nodeTreeEquals(expectNode));
  });

  test('test custom parser', () {
    final source = '''
    [img src="https://example.com/avatar.png"] hello world, I'm @foo [smile], my email 
    is foo@example.com, blog address is https://foo.example.com .
    ''';
    // final expectNode = Element('root', [
    //   Element.empty('img')
    //     ..attributes.addAll({
    //       'src': 'https://example.com/avatar.png',
    //     }),
    //   Text("hello world, I'm "),
    //   Element('at', [Text('foo')])..attributes.addAll({'id': 'foo'}),
    //   Text(", my email is "),
    //   Element('email', [Text('foo@example.com')]),
    //   Text(", blog address is "),
    //   Element('url', [Text('https://foo.example.com')])
    //     ..attributes.addAll({'url': 'https://foo.example.com'}),
    //   Text(" ."),
    // ]);
    //
    // final doc = Document(
    //   source,
    //   // parserBuilder: SquareBracketParser.builder,
    // );
    // final rootNode = doc.parse();
    // expect(rootNode, nodeTreeEquals(expectNode));
  });
}
