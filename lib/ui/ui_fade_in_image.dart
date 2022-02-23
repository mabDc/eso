import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../page/photo_view_page.dart';
import 'widgets/image_place_holder.dart';

class UIFadeInImage extends StatelessWidget {
  final PhotoItem item;
  final double placeHolderWidth;
  final double placeHolderHeight;
  final BoxFit fit;
  const UIFadeInImage({
    this.item,
    this.fit,
    this.placeHolderHeight = 400,
    this.placeHolderWidth = 400,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startIndex = item.url.indexOf(";base64,");
    if (startIndex > -1) {
      try {
        return Image.memory(
          base64Decode(item.url.substring(startIndex + 8)),
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, url, err) {
            return ImagePlaceHolder(
              height: placeHolderHeight,
              width: placeHolderWidth,
              error: true,
            );
          },
        );
      } catch (e) {
        return ImagePlaceHolder(
          height: placeHolderHeight,
          width: placeHolderWidth,
          error: true,
        );
      }
    }
    return CachedNetworkImage(
      imageUrl: item.url,
      httpHeaders: item.headers,
      placeholder: (context, url) {
        return ImagePlaceHolder(
          height: placeHolderHeight,
          width: placeHolderWidth,
        );
      },
      fit: fit ?? BoxFit.cover,
      errorWidget: (context, url, err) {
        return ImagePlaceHolder(
          height: placeHolderHeight,
          width: placeHolderWidth,
          error: true,
        );
      },
    );
  }
}
