import 'package:flutter/material.dart';

import '../../global.dart';

class ImagePlaceHolder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(color: Theme.of(context).dividerColor, width: Global.lineSize),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, color: Theme.of(context).primaryColor.withOpacity(0.2), size: 64),
            SizedBox(height: 2),
            Text("eso", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.1)))
          ],
        ),
      ),
    );
  }
}