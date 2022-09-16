// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:provider/provider.dart';

// import '../../eso_theme.dart';

// class ColorLensPage extends StatelessWidget {
//   const ColorLensPage({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final profile = ESOTheme();
//     Color currentColor = Color(profile.primaryColor);
//     void Function(Color color) changeColor =
//         (Color color) => profile.primaryColor = color.value;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('调色板'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               constraints: BoxConstraints(maxWidth: 320),
//               child: ColorPicker(
//                 pickerColor: currentColor,
//                 onColorChanged: changeColor,
//                 pickerAreaHeightPercent: 0.6,
//                 enableAlpha: false,
//               ),
//             ),
//             Divider(),
//             Wrap(
//               children: [
//                 SlidePicker(
//                   pickerColor: currentColor,
//                   onColorChanged: changeColor,
//                   colorModel: ColorModel.rgb,
//                   showIndicator: false,
//                   enableAlpha: false,
//                   indicatorBorderRadius: const BorderRadius.vertical(
//                     top: const Radius.circular(10.0),
//                   ),
//                 ),
//                 SlidePicker(
//                   pickerColor: currentColor,
//                   onColorChanged: changeColor,
//                   colorModel: ColorModel.hsl,
//                   showIndicator: false,
//                   enableAlpha: false,
//                   indicatorBorderRadius: const BorderRadius.vertical(
//                     top: const Radius.circular(10.0),
//                   ),
//                 ),
//                 SlidePicker(
//                   pickerColor: currentColor,
//                   onColorChanged: changeColor,
//                   colorModel: ColorModel.hsv,
//                   showIndicator: false,
//                   enableAlpha: false,
//                   indicatorBorderRadius: const BorderRadius.vertical(
//                     top: const Radius.circular(10.0),
//                   ),
//                 ),
//               ],
//             ),
//             Divider(),
//             BlockPicker(
//               pickerColor: currentColor,
//               onColorChanged: changeColor,
//             ),
//             Divider(),
//             MaterialPicker(
//               pickerColor: currentColor,
//               onColorChanged: changeColor,
//               enableLabel: true,
//             ),
//             Divider(),
//           ],
//         ),
//       ),
//     );
//   }
// }
