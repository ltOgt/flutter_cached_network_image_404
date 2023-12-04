// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

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

  CachedNetworkImageProvider? imageProvider;

  @override
  void initState() {
    super.initState();
    setProvider();
  }

  void setProvider() {
    setState(() {
      imageProvider = CachedNetworkImageProvider(imageUrl);
    });
  }

  void setProviderNull() {
    setState(() {
      imageProvider = null;
    });
  }

  final changeUrl = 'http://localhost:8080/changeImage';
  final imageUrl = 'http://localhost:8080/getImage';
  final toggleReturnUrl = 'http://localhost:8080/toggle404';

  void _clearCache() {
    /// This alone does work, but throws away etag etc
    ///
    /// Also, we need to know the exact url
    ///
    /// Calls ImageCache.evict(CachedNetworkImage(imageUrl))
    ///
    //await CachedNetworkImage.evictFromCache(imageUrl);

    // Use the following to brute force clear all if you dont know the exact url
    // PaintingBinding.instance.imageCache.clearLiveImages();
    // PaintingBinding.instance.imageCache.clear();

    // Use the following if you know tfluthe exact URL you want to refresh
    PaintingBinding.instance.imageCache.evict(CachedNetworkImageProvider(imageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer - $lastUpdate'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            foregroundImage: imageProvider,
            radius: 100,
            onForegroundImageError: imageProvider == null
                ? null
                : (_, __) {
                    // ⚡️ this is not called on 404
                    CachedNetworkImage.evictFromCache(imageProvider!.url);
                    setProviderNull();
                  },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await http.get(Uri.parse(changeUrl));
              _clearCache();
              setProvider();
            },
            child: const Text('Change Image. Aka upload different profile picture.'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _clearCache();
              setProvider();
            },
            child: const Text('Clear ImageCache without Image Change'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              http.get(Uri.parse(toggleReturnUrl));
              _clearCache();
              setProvider();
            },
            child: const Text('Toggle return nothing. Aka delete profile picture'),
          ),
        ],
      ),
    );
  }
}
