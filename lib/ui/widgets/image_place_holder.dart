import 'package:eso/model/profile.dart';
import 'package:flutter/material.dart';

import '../../global.dart';

class ImagePlaceHolder extends StatelessWidget {
  final double height;
  final double width;
  final bool error;
  const ImagePlaceHolder({Key key, this.height, this.width, this.error = false}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).dividerColor.withOpacity(0.02),
      shape: Border.all(color: Theme.of(context).dividerColor, width: Global.lineSize),
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(error ? Icons.broken_image : Icons.image, color: Theme.of(context).primaryColor.withOpacity(0.2), size: 64),
              SizedBox(height: 2),
              Text("eso", style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: Profile.staticFontFamily,
                  color: Theme.of(context).primaryColor.withOpacity(0.1)))
            ],
          ),
        ),
      ),
    );
  }
}