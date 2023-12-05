// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart' as fcm;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime lastUpdate = DateTime.now();

  CachedNetworkImageProvider? imageProvider1;
  CachedNetworkImageProvider? imageProvider2;
  CachedNetworkImageProvider? imageProvider3;

  @override
  void initState() {
    super.initState();
    setProvider();
  }

  void setProvider() {
    setState(() {
      imageProvider1 = CachedNetworkImageProvider("$imageUrl?size=150");
      imageProvider2 = CachedNetworkImageProvider("$imageUrl?size=100");
      imageProvider3 = CachedNetworkImageProvider("$imageUrl?size=50");
    });
  }

  void setProviderNull() {
    setState(() {
      imageProvider1 = null;
      imageProvider2 = null;
      imageProvider3 = null;
    });
  }

  final changeUrl = 'http://localhost:8080/changeImage';
  final imageUrl = 'http://localhost:8080/getImage';
  final toggleReturnUrl = 'http://localhost:8080/toggle404';

  void _clearImageCacheToForceRefresh() {
    final allCachedKeys = fcm.DefaultCacheManager().getKeysFromMemory();

    final imageCache = PaintingBinding.instance.imageCache;
    print("Size before evict (expect 4): ${imageCache.currentSize}");
    for (final key in allCachedKeys.where((url) => url.startsWith(imageUrl))) {
      imageCache.evict(CachedNetworkImageProvider(key));
    }
    print("Size after evict (expect 1): ${imageCache.currentSize}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer - $lastUpdate'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Unrelated image that should not be removed from ImageCache
            CachedNetworkImage(imageUrl: "https://picsum.photos/536/354"),

            /// Three versions of the same resource that should be removed together
            CircleAvatar(
              foregroundImage: imageProvider1,
              radius: 150,
            ),
            CircleAvatar(
              foregroundImage: imageProvider2,
              radius: 100,
            ),
            CircleAvatar(
              foregroundImage: imageProvider3,
              radius: 50,
            ),

            ///
            ///
            ///
            ///
            ///
            ///
            ///
            ///
            ///
            // ===================

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await http.get(Uri.parse(changeUrl));
                _clearImageCacheToForceRefresh();
                setProvider();
              },
              child: const Text('Change Image. Aka upload different profile picture.'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _clearImageCacheToForceRefresh();
                setProvider();
              },
              child: const Text('Clear ImageCache without Image Change'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                http.get(Uri.parse(toggleReturnUrl));
                _clearImageCacheToForceRefresh();
                setProvider();
              },
              child: const Text('Toggle return nothing. Aka delete profile picture'),
            ),
          ],
        ),
      ),
    );
  }
}
