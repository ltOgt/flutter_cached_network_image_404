import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

// Configure routes.
final _router = Router()
  ..get('/getImage', _getImage)
  ..get('/changeImage', _changeImage)
  ..get('/toggle404', _toggle404);

// Map to store current image details
Map<String, dynamic> get imageDetails => image1
    ? {
        'image': 'https://fastly.picsum.photos/id/971/200/200.jpg?hmac=xcJY-VNIH_UD01lMlLi4mADmQrLTgoEE2_NYEhL3VQA',
        'etag': '123',
      }
    : {
        'image': 'https://fastly.picsum.photos/id/219/200/200.jpg?hmac=A55nsncpsnDAEPuZjs3_12i2n8HJNZ5-1SVCIN2fAgc',
        'etag': '456',
      };

bool image1 = true;
final cacheControl = 'max-age=5, public'; // 5 seconds

bool returnNothing = false;

/// Returns one of two images for the same URL.
/// See [_changeImage].
///
/// Or no image at all (404).
/// See [_toggle404].
Future<Response> _getImage(Request req) async {
  if (returnNothing) {
    return Response.notFound("");
  }

  var imageUrl = imageDetails['image'];
  var imageResponse = await http.get(Uri.parse(imageUrl));

  final currentEtag = imageDetails['etag'];
  final headerEtag = req.headers[HttpHeaders.ifNoneMatchHeader];

  if (currentEtag == headerEtag) {
    return Response.notModified(
      headers: {
        'Cache-Control': cacheControl,
        'ETag': currentEtag,
      },
    );
  }

  return Response.ok(
    Uint8List.fromList(imageResponse.bodyBytes),
    headers: {
      'Content-Type': 'image/jpeg',
      'Cache-Control': cacheControl,
      'ETag': currentEtag,
    },
  );
}

/// Switches between one of two images
/// that will be returned from [_getImage].
///
/// Simulates e.g. a User changing their profile picture.
Response _changeImage(Request request) {
  image1 = !image1;
  log("Now image ${image1 ? 1 : 2}");

  return Response.ok("");
}

/// Switches between returning an image or 404 from [_getImage].
///
/// Simulates e.g. a User deleting their profile picture.
Response _toggle404(Request request) {
  returnNothing = !returnNothing;
  log("Now returning ${returnNothing ? 'nothing' : 'something'}");

  return Response.ok("");
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
