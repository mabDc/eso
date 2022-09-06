import 'package:hive_flutter/hive_flutter.dart';

import 'hive_type_id.dart';

class ESOTheme extends HiveObject {
  int boxFit;
  int opacity;
  int color;
  int iconColor;
  String imagePath;
  ESOTheme({this.boxFit, this.opacity, this.color, this.iconColor, this.imagePath});
}


class ESOThemeAdapter extends TypeAdapter<ESOTheme> {
  @override
  ESOTheme read(BinaryReader reader) {
    final boxFit = reader.readInt(),
        opacity = reader.readInt(),
        color = reader.readInt(),
        iconColor = reader.readInt(),
        imagePath = reader.readString();
    return ESOTheme(
      boxFit: boxFit,
      opacity: opacity,
      color: color,
      iconColor: iconColor,
      imagePath: imagePath,
    );
  }

  @override
  int get typeId => esoThemeTypeId;

  @override
  void write(BinaryWriter writer, ESOTheme esoTheme) {
    writer.writeInt(esoTheme.boxFit);
    writer.writeInt(esoTheme.opacity);
    writer.writeInt(esoTheme.color);
    writer.writeInt(esoTheme.iconColor);
    writer.writeString(esoTheme.imagePath);
  }
}

// BoxDecoration globalDecoration = BoxDecoration(
//   color: Colors.white,
//   image: DecorationImage(
//     fit: BoxFit.fitWidth,
//     opacity: 0.8,
//     image: AssetImage(
//       "assets/ba/水12.jpg",
//     ),
//   ),
// );
