import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
  });

  tearDown(() => p.kill());

  test('Test image retrieval and update', () async {
    // Get image and note etag
    var response = await get(Uri.parse('$host/getImage'));
    expect(response.statusCode, 200);
    var initialEtag = response.headers['etag'];
    expect(initialEtag, isNotNull);
    print("got first $initialEtag");

    await Future.delayed(Duration(seconds: 2));

    // Get image again and note unchanged etag
    response = await get(
      Uri.parse('$host/getImage'),
      headers: {
        HttpHeaders.ifNoneMatchHeader: initialEtag!,
      },
    );
    expect(response.statusCode, 304);
    var sameEtag = response.headers['etag'];
    expect(initialEtag, equals(sameEtag));
    print("got second $sameEtag");

    await Future.delayed(Duration(seconds: 2));

    // Trigger an image change
    response = await get(Uri.parse('$host/changeImage'));
    expect(response.statusCode, 200);
    print("changed");

    // Now the etag should be different
    response = await get(Uri.parse('$host/getImage'));
    expect(response.statusCode, 200);
    var changedEtag = response.headers['etag'];
    expect(changedEtag, isNot(equals(sameEtag)));
    print("got third $changedEtag");
  });
}
