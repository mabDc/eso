 import 'package:flutter/material.dart';
 import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

 class ZoomView extends StatefulWidget {
   final Widget child;

   const ZoomView({Key key, this.child}) : super(key: key);
   @override
   _ZoomViewState createState() => _ZoomViewState();
 }

 class _ZoomViewState extends State<ZoomView> {
   Matrix4 matrix = Matrix4.identity();

   @override
   Widget build(BuildContext context) {
     return MatrixGestureDetector(
       onMatrixUpdate: (m, tm, sm, rm) {
         setState(() {
           //缩放为1禁止平移
           if (matrix[0] <= 1) {
             tm = Matrix4.identity();
           }
           matrix = MatrixGestureDetector.compose(matrix, tm, sm, null);
           //缩放小于1则修正为1
           if (matrix[0] - sm[0] < 0) {
             matrix = Matrix4.diagonal3Values(1, 1, 1);
           }
         });
       },
       child: Transform(
         transform: matrix,
         child: widget.child,
       ),
     );
   }
 }
