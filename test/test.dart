import 'dart:io';

import 'package:path/path.dart' as path;

final String assetRoot = Directory.current.path.endsWith('test')
    ? path.join(Directory.current.path, 'assets')
    : path.join(Directory.current.path, 'test/assets');

String findAsset(String assetName) => '$assetRoot/$assetName';

File openAsset(String assetName) => File(findAsset(assetName));
