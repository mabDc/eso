import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import 'widgets/image_place_holder.dart';

class UIFadeInImage extends StatelessWidget {
  final String url;
  final Map<String, String> header;
  final double placeHolderHeight;
  final BoxFit fit;
  UIFadeInImage({this.url, this.header, this.fit, this.placeHolderHeight, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: header,
      placeholder: (context, url) {
        return ImagePlaceHolder(height: placeHolderHeight);
      },
      fit: fit ?? BoxFit.cover,
      errorWidget: (context, url, err) {
        return Image.asset(Global.nowayPath, fit: fit ?? BoxFit.cover);
      },
    );
  }
}

//class _UIFadeInImageState extends State<UIFadeInImage> {
//  bool error;
//
//  @override
//  void initState() {
//    error = false;
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // 避免error为null
//    return CachedNetworkImage(
//      imageUrl: widget.url,
//      httpHeaders: widget.header,
//      placeholder: (context, url) {
//        return ImagePlaceHolder(height: widget.placeHolderHeight);
//      },
//      fit: widget.fit ?? BoxFit.cover,
//      errorWidget: (context, url, err) {
//        return Image.asset(Global.nowayPath, fit: widget.fit ?? BoxFit.cover);
//      },
//    );
////    if (error == true) {
////      return Image.asset(Global.nowayPath, fit: widget.fit ?? BoxFit.cover);
////    }
////
////    final image = FadeInImage(
////      placeholder: AssetImage(Global.waitingPath),
////      image: NetworkImage(widget.url, headers: widget.header),
////      fit: widget.fit ?? BoxFit.cover,
////    );
////    final ImageStream stream = image.image.resolve(ImageConfiguration.empty);
////    stream.addListener(
////      ImageStreamListener(
////        (_, __) {},
////        onError: (dynamic exception, StackTrace stackTrace) {
////          setState(() {
////            error = true;
////          });
////        },
////      ),
////    );
////    return image;
//  }
//}
