import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'widgets/image_place_holder.dart';

class UIFadeInImage extends StatelessWidget {
  final String url;
  final Map<String, String> header;
  final double placeHolderWidth;
  final double placeHolderHeight;
  final BoxFit fit;
  UIFadeInImage({
    this.url,
    this.header,
    this.fit,
    this.placeHolderHeight,
    this.placeHolderWidth,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startIndex = url.indexOf(";base64,");
    if (startIndex > -1) {
      try {
        return Image.memory(
          base64Decode(url.substring(startIndex + 8)),
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
      imageUrl: url,
      httpHeaders: header,
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
