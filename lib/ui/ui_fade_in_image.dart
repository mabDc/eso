import 'package:flutter/material.dart';

import '../global.dart';

class UIFadeInImage extends StatefulWidget {
  final String url;
  final Map<String, String> header;
  UIFadeInImage({this.url, this.header, Key key}) : super(key: key);

  @override
  _UIFadeInImageState createState() => _UIFadeInImageState();
}

class _UIFadeInImageState extends State<UIFadeInImage> {
  bool error;

  @override
  void initState() {
    error = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 避免error为null
    if (error == true) {
      return Image.asset(Global.nowayPath, fit: BoxFit.cover,);
    }
    final image = FadeInImage(
      placeholder: AssetImage(Global.waitingPath),
      image: NetworkImage(widget.url, headers: widget.header),
      fit: BoxFit.cover,
    );
    final ImageStream stream = image.image.resolve(ImageConfiguration.empty);
    stream.addListener(
      ImageStreamListener(
        (_, __) {},
        onError: (dynamic exception, StackTrace stackTrace) {
          setState(() {
            error = true;
          });
        },
      ),
    );
    return image;
  }
}
