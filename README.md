# Simple server + client to test flutter_cached_network_image

## Main issues
- flutter_cached_network_image does not provide a way to refresh images that have changed on the server, but have the same url as before
    - The main issue here is that `ImageProvider.resolveStreamForKey` only calls `ImageProvider.loadImage` through `ImageCache.putIfAbsent`.
    - This means that all the good caching logic with `if-none-match` etc is only called once during the apps lifetime, when the URL is used for the first time and is not yet registered in `ImageCache`.
    - Quick Fix: `PaintingBinding.instance.imageCache.evict(CachedNetworkImageProvider(url), includeLive: true)`

- flutter_cached_network_image does not clear its cache on 404, and does not surface the error to callbacks like `CircleAvatar.onForegroundImageError`


        


## cai_server
A dart server with the following endpoints
- /getImage
    - Returns one of two images for the same url
        - can be changed with /changeImage
        - can return 404 after /toggle404
    - Simulates e.g. a profile picture URL
- /changeImage
    - Changes the image returned from /getImage
    - Simulates e.g. a user changing their profile picture
- /toggle404
    - Causes /getImage to return 404
    - Simulates e.g. a user deleting their profile picture

## cai_client
Slim flutter client that calls cai_server endpoints
and uses flutter_cached_network_image

## cai_js.html
Pure html+jss to compare to browser behaviour.


# How to use
start both cai_server and cai_client.

press buttons in the client and observe the debug console in the server
