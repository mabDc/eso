import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:cached_network_image'
        '/cached_network_image_platform_interface.dart' as platform
    show ImageLoader;
import 'package:cached_network_image'
        '/cached_network_image_platform_interface.dart'
    show ImageRenderMethodForWeb;

/// ImageLoader class to load images on IO platforms.
class ImageLoader implements platform.ImageLoader {
  @override
  Stream<ui.Codec> loadAsync(
    String url,
    OnDecrypt? decrypt,
    String? cacheKey,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderCallback decode,
    BaseCacheManager cacheManager,
    int? maxHeight,
    int? maxWidth,
    Map<String, String>? headers,
    Function()? errorListener,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    Function() evictImage,
  ) async* {
    try {
      // print("loadAsync:${url},headers:${headers}");

      assert(
          cacheManager is ImageCacheManager ||
              (maxWidth == null && maxHeight == null),
          'To resize the image with a CacheManager the '
          'CacheManager needs to be an ImageCacheManager. maxWidth and '
          'maxHeight will be ignored when a normal CacheManager is used.');

      var stream = cacheManager is ImageCacheManager
          ? cacheManager.getImageFile(url,
              maxHeight: maxHeight,
              maxWidth: maxWidth,
              withProgress: true,
              headers: headers,
              key: cacheKey)
          : cacheManager.getFileStream(url,
              withProgress: true, headers: headers, key: cacheKey);
      // print("stream:${stream}");

      await for (var result in stream) {
        if (result is DownloadProgress) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: result.downloaded,
            expectedTotalBytes: result.totalSize,
          ));
        }
        // print("result:${result}");
        if (result is FileInfo) {
          var file = result.file;
          // print("file:${file.path}");
          var bytes = await file.readAsBytes();

          var decBytes = await decrypt!(bytes);

          var decoded = await decode(decBytes);
          yield decoded;
        }
      }
    } catch (e) {
      print("error:${e}");
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        evictImage();
      });

      errorListener?.call();
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }
}
