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
