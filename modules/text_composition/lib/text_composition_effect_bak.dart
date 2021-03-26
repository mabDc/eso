// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:vector_math/vector_math_64.dart' as v;
// import 'package:flutter/material.dart';

// import 'text_composition.dart';

// class TextCompositionEffect extends CustomPainter {
//   TextCompositionEffect({
//     required this.amount,
//     required this.index,
//     required this.config,
//     required this.textComposition,
//     this.radius = 0.18,
//   }) : super(repaint: amount);

//   final Animation<double> amount;
//   ui.Image? image;
//   bool? toImageIng;
//   bool? toPictureIng;
//   ui.Picture? picture;
//   final double radius;
//   final int index;
//   final TextCompositionConfig config;
//   final TextComposition textComposition;

//   /// 原始动效
//   void paintCurl(ui.Canvas canvas, ui.Size size, double pos, ui.Image image,
//       Color? backgroundColor) {
//     final movX = (1.0 - pos) * 0.85;
//     final calcR = (movX < 0.20) ? radius * movX * 5 : radius;
//     final wHRatio = 1 - calcR;
//     final hWRatio = image.height / image.width;
//     final hWCorrection = (hWRatio - 1.0) / 2.0;

//     final w = size.width.toDouble();
//     final h = size.height.toDouble();
//     final c = canvas;
//     final shadowXf = (wHRatio - movX);
//     final shadowSigma = Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - shadowXf)));
//     final pageRect = Rect.fromLTRB(0.0, 0.0, w * shadowXf, h);
//     if (backgroundColor != null) {
//       c.drawRect(pageRect, Paint()..color = backgroundColor);
//     }
//     if (pos != 0) {
//       c.drawRect(
//         pageRect,
//         Paint()
//           ..color = Colors.black54
//           ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
//       );
//     }

//     final ip = Paint();
//     for (double x = 0; x < size.width; x++) {
//       final xf = (x / w);
//       final v = (calcR * (math.sin(math.pi / 0.5 * (xf - (1.0 - pos)))) + (calcR * 1.1));
//       final xv = (xf * wHRatio) - movX;
//       final sx = (xf * image.width);
//       final sr = Rect.fromLTRB(sx, 0.0, sx + 1.0, image.height.toDouble());
//       final yv = ((h * calcR * movX) * hWRatio) - hWCorrection;
//       final ds = (yv * v);
//       final dr = Rect.fromLTRB(xv * w, 0.0 - ds, xv * w + 1.0, h + ds);
//       c.drawImageRect(image, sr, dr, ip);
//     }
//   }

//   @override
//   bool shouldRepaint(TextCompositionEffect oldDelegate) {
//     return oldDelegate.image != image ||
//         oldDelegate.picture != picture ||
//         oldDelegate.amount.value != amount.value ||
//         index != oldDelegate.index;
//   }

//   @override
//   void paint(ui.Canvas canvas, ui.Size size) {
//     final textPage = textComposition.textPages[index];
//     if (textPage == null) {
//       // 画正好加载最后章节
//       return;
//     }
//     if (index > textComposition.currentIndex + 3) return;
//     if (index < textComposition.currentIndex - 3) return;

//     ///初始化
//     if (picture == null) {
//       if (toPictureIng == true) return;
//       toPictureIng = true;
//       final pic = ui.PictureRecorder();
//       final c = Canvas(pic);
//       final pageRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
//       c.drawRect(pageRect, Paint()..color = config.backgroundColor);
//       paintText(c, size, textPage, config);
//       picture = pic.endRecording();
//       toPictureIng = false;
//       if (config.animation == 'simulation') calcCornerXY(size.width, size.height, size);
//     }

//     if (config.animation == 'curl' && image == null) {
//       if (toImageIng == true) return;

//       if (config.animationHighImage) {
//         final pic = ui.PictureRecorder();
//         final c = Canvas(pic);
//         c.scale(ui.window.devicePixelRatio);
//         paintText(c, size, textPage, config);
//         pic
//             .endRecording()
//             .toImage(ui.window.physicalSize.width.round(),
//                 ui.window.physicalSize.height.round())
//             .then((value) {
//           image = value;
//           toImageIng = false;
//         });
//       } else {
//         picture!.toImage(size.width.round(), size.height.round()).then((value) {
//           image = value;
//           toImageIng = false;
//         });
//       }
//     }

//     final pos = amount.value;
//     if (pos < 0.002) return;

//     /// 这里开始画，先判断上一页 在画当前页
//     /// 如果上一页还有东西 直接裁剪或者不画 也许会节约资源？？
//     final pP = textComposition.getAnimationPostion(index - 1);
//     if (pP > 0.996) {
//       return;
//     } else if (pP > 0.2) {
//       canvas.clipRect(Rect.fromLTRB((pP - 0.2) * size.width, 0, size.width, size.height));
//     }

//     if (config.showStatus && !config.animationStatus) {
//       canvas.clipRect(Rect.fromLTRB(0, ui.window.padding.top / ui.window.devicePixelRatio,
//           size.width, size.height));
//     }

//     if (pos > 0.996) {
//       canvas.drawPicture(picture!);
//     } else if (config.animation == 'simulation') {
//       final x = pos * size.width;
//       calBezierPoint(Offset(x, size.height), size);
//       onDraw(canvas, Offset(x, size.height), size, picture!);
//     } else if (config.animation == 'flip') {
//       if (pos > 0.5) {
//         print("begin canvas.drawPicture(picture!); ${DateTime.now()}");
//         canvas.drawPicture(picture!);
//         print("end canvas.drawPicture(picture!); ${DateTime.now()}");
//         canvas.clipRect(Rect.fromLTRB(size.width / 2, 0, size.width, size.height));
//         () {
//           final nextpage = textComposition.textPages[index + 1];
//           if (nextpage == null) return;
//           final pageRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
//           canvas.drawRect(pageRect, Paint()..color = config.backgroundColor);
//           print("begin paintText ${DateTime.now()}");
//           paintText(canvas, size, nextpage, config);
//           print("end paintText ${DateTime.now()}");
//         }();

//         canvas.translate(size.width / 2, 0);
//         canvas.transform((Matrix4.identity()
//               ..setEntry(3, 2, 0.0005)
//               ..rotateY(math.pi * (1 - pos))
//               ..translate(-size.width / 2, 0, 0))
//             .storage);

//         // canvas.translate(size.width / 2, 0);
//         canvas.drawPicture(picture!);
//         canvas.drawRect(
//           Offset.zero & size,
//           Paint()
//             ..color = Colors.black54
//             ..maskFilter = MaskFilter.blur(BlurStyle.outer, 20),
//         );
//       } else {
//         final nextpage = textComposition.textPages[index + 1];
//         if (nextpage == null) return;

//         final pic = ui.PictureRecorder();
//         final c = Canvas(pic);
//         final pageRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
//         c.drawRect(pageRect, Paint()..color = config.backgroundColor);
//         paintText(c, size, nextpage, config);
//         final picture2 = pic.endRecording();
//         canvas.drawPicture(picture2);

//         canvas.clipRect(Rect.fromLTRB(0, 0, size.width / 2, size.height));
//         canvas.drawPicture(picture!);
//         canvas.translate(size.width / 2, 0);
//         canvas.transform((Matrix4.identity()
//               ..setEntry(3, 2, 0.0005)
//               ..rotateY(-math.pi * pos)
//               ..translate(-size.width / 2, 0, 0))
//             .storage);
//         canvas.drawPicture(picture2);
//         canvas.drawRect(
//           Offset.zero & size,
//           Paint()
//             ..color = Colors.black54
//             ..maskFilter = MaskFilter.blur(BlurStyle.outer, 20),
//         );
//       }
//     } else if (config.animation == 'cover') {
//       final shadowSigma = Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - pos)));
//       final pageRect = Rect.fromLTRB(0.0, 0.0, size.width * pos, size.height.toDouble());
//       canvas.drawRect(pageRect, Paint()..color = config.backgroundColor);
//       canvas.drawRect(
//         pageRect,
//         Paint()
//           ..color = Colors.black54
//           ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
//       );
//       canvas.translate(2 + size.width * (pos - 1.0), 0);
//       canvas.drawPicture(picture!);
//     } else if (config.animation == 'curl') {
//       if (image == null) {
//         if (toImageIng == true) return;
//         toImageIng = true;

//         if (config.animationHighImage) {
//           final pic = ui.PictureRecorder();
//           final c = Canvas(pic);
//           c.scale(ui.window.devicePixelRatio);
//           paintText(c, size, textPage, config);
//           pic
//               .endRecording()
//               .toImage(ui.window.physicalSize.width.round(),
//                   ui.window.physicalSize.height.round())
//               .then((value) {
//             image = value;
//             toImageIng = false;
//           });
//         } else {
//           picture!.toImage(size.width.round(), size.height.round()).then((value) {
//             image = value;
//             toImageIng = false;
//           });
//         }
//       } else {
//         // canvas.translate(size.width / 2, 0);
//         paintCurl(canvas, size, pos, image!, config.backgroundColor);
//       }
//     }
//   }

//   /// 下面来自 https://github.com/lwlizhe/flutter_novel/blob/master/lib/app/novel/widget/reader/content/helper/animation/animation_page_simulation_turn.dart
//   /// 可以继续修改
//   bool isStartAnimation = false;
//   Offset minDragDistance = Offset(10, 10);

//   Path mTopPagePath = Path();
//   Path mBottomPagePath = Path();
//   Path mTopBackAreaPagePath = Path();
//   Path mShadowPath = Path();

//   double mCornerX = 1; // 拖拽点对应的页脚
//   double mCornerY = 1;

//   late bool mIsRTandLB; // 是否属于右上左下

//   Offset mBezierStart1 = new Offset(0, 0); // 贝塞尔曲线起始点
//   Offset mBezierControl1 = new Offset(0, 0); // 贝塞尔曲线控制点
//   Offset mBezierVertex1 = new Offset(0, 0); // 贝塞尔曲线顶点
//   Offset mBezierEnd1 = new Offset(0, 0); // 贝塞尔曲线结束点

//   Offset mBezierStart2 = new Offset(0, 0); // 另一条贝塞尔曲线
//   Offset mBezierControl2 = new Offset(0, 0);
//   Offset mBezierVertex2 = new Offset(0, 0);
//   Offset mBezierEnd2 = new Offset(0, 0);

//   late double mMiddleX;
//   late double mMiddleY;
//   late double mDegrees;
//   late double mTouchToCornerDis;

//   late double mMaxLength;

//   TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

//   bool isTurnToNext = false;
//   bool isConfirmAnimation = false;

//   void calBezierPoint(Offset mTouch, Size currentSize) {
//     mMiddleX = (mTouch.dx + mCornerX) / 2;
//     mMiddleY = (mTouch.dy + mCornerY) / 2;

//     mMaxLength =
//         math.sqrt(math.pow(currentSize.width, 2) + math.pow(currentSize.height, 2));

//     mBezierControl1 = Offset(
//         mMiddleX - (mCornerY - mMiddleY) * (mCornerY - mMiddleY) / (mCornerX - mMiddleX),
//         mCornerY.toDouble());

//     double f4 = mCornerY - mMiddleY;
//     if (f4 == 0) {
//       mBezierControl2 = Offset(mCornerX.toDouble(),
//           mMiddleY - (mCornerX - mMiddleX) * (mCornerX - mMiddleX) / 0.1);
//     } else {
//       mBezierControl2 = Offset(
//           mCornerX.toDouble(),
//           mMiddleY -
//               (mCornerX - mMiddleX) * (mCornerX - mMiddleX) / (mCornerY - mMiddleY));
//     }

//     mBezierStart1 = Offset(
//         mBezierControl1.dx - (mCornerX - mBezierControl1.dx) / 2, mCornerY.toDouble());

//     // 当mBezierStart1.x < 0或者mBezierStart1.x > 480时
//     // 如果继续翻页，会出现BUG故在此限制
//     if (mTouch.dx > 0 && mTouch.dx < currentSize.width) {
//       if (mBezierStart1.dx < 0 || mBezierStart1.dx > currentSize.width) {
//         if (mBezierStart1.dx < 0) {
//           mBezierStart1 = Offset(currentSize.width - mBezierStart1.dx, mBezierStart1.dy);
//         }

//         double f1 = (mCornerX - mTouch.dx).abs();
//         double f2 = currentSize.width * f1 / mBezierStart1.dx;
//         mTouch = Offset((mCornerX - f2).abs(), mTouch.dy);

//         double f3 = (mCornerX - mTouch.dx).abs() * (mCornerY - mTouch.dy).abs() / f1;
//         mTouch = Offset((mCornerX - f2).abs(), (mCornerY - f3).abs());

//         mMiddleX = (mTouch.dx + mCornerX) / 2;
//         mMiddleY = (mTouch.dy + mCornerY) / 2;

//         mBezierControl1 = Offset(
//             mMiddleX -
//                 (mCornerY - mMiddleY) * (mCornerY - mMiddleY) / (mCornerX - mMiddleX),
//             mCornerY);

//         double f5 = mCornerY - mMiddleY;
//         if (f5 == 0) {
//           mBezierControl2 = Offset(
//               mCornerX, mMiddleY - (mCornerX - mMiddleX) * (mCornerX - mMiddleX) / 0.1);
//         } else {
//           mBezierControl2 = Offset(
//               mCornerX,
//               mMiddleY -
//                   (mCornerX - mMiddleX) * (mCornerX - mMiddleX) / (mCornerY - mMiddleY));
//         }

//         mBezierStart1 = Offset(
//             mBezierControl1.dx - (mCornerX - mBezierControl1.dx) / 2, mBezierStart1.dy);
//       }
//     }

//     mBezierStart2 = Offset(
//         mCornerX.toDouble(), mBezierControl2.dy - (mCornerY - mBezierControl2.dy) / 2);

//     mTouchToCornerDis = math
//         .sqrt(math.pow((mTouch.dx - mCornerX), 2) + math.pow((mTouch.dy - mCornerY), 2));

//     mBezierEnd1 = getCross(mTouch, mBezierControl1, mBezierStart1, mBezierStart2);
//     mBezierEnd2 = getCross(mTouch, mBezierControl2, mBezierStart1, mBezierStart2);

//     mBezierVertex1 = Offset(
//         (mBezierStart1.dx + 2 * mBezierControl1.dx + mBezierEnd1.dx) / 4,
//         (2 * mBezierControl1.dy + mBezierStart1.dy + mBezierEnd1.dy) / 4);

//     mBezierVertex2 = Offset(
//         (mBezierStart2.dx + 2 * mBezierControl2.dx + mBezierEnd2.dx) / 4,
//         (2 * mBezierControl2.dy + mBezierStart2.dy + mBezierEnd2.dy) / 4);
//   }

//   /// 获取交点 ///
//   Offset getCross(Offset p1, Offset p2, Offset p3, Offset p4) {
//     // 二元函数通式： y=kx+b(k是斜率)
//     double k1 = (p2.dy - p1.dy) / (p2.dx - p1.dx);
//     double b1 = ((p1.dx * p2.dy) - (p2.dx * p1.dy)) / (p1.dx - p2.dx);

//     double k2 = (p4.dy - p3.dy) / (p4.dx - p3.dx);
//     double b2 = ((p3.dx * p4.dy) - (p4.dx * p3.dy)) / (p3.dx - p4.dx);

//     return Offset((b2 - b1) / (k1 - k2), k1 * ((b2 - b1) / (k1 - k2)) + b1);
//   }

//   /// 计算拖拽点对应的拖拽脚 ///
//   void calcCornerXY(double x, double y, Size currentSize) {
//     if (x <= currentSize.width / 2) {
//       mCornerX = 0;
//     } else {
//       mCornerX = currentSize.width;
//     }
//     if (y <= currentSize.height / 2) {
//       mCornerY = 0;
//     } else {
//       mCornerY = currentSize.height;
//     }

//     if ((mCornerX == 0 && mCornerY == currentSize.height) ||
//         (mCornerX == currentSize.width && mCornerY == 0)) {
//       mIsRTandLB = true;
//     } else {
//       mIsRTandLB = false;
//     }
//   }

//   void onDraw(Canvas canvas, Offset mTouch, Size currentSize, ui.Picture picture) {
//     drawTopPageCanvas(canvas, mTouch, currentSize, picture);
//     drawTopPageBackArea(canvas, mTouch, currentSize, picture);
//   }

//   /// 画在最顶上的那页 ///
//   void drawTopPageCanvas(
//       Canvas canvas, Offset mTouch, Size currentSize, ui.Picture picture) {
//     mTopPagePath.reset();

//     mTopPagePath.moveTo(mCornerX == 0 ? currentSize.width : 0, mCornerY);
//     mTopPagePath.lineTo(mBezierStart1.dx, mBezierStart1.dy);
//     mTopPagePath.quadraticBezierTo(
//         mBezierControl1.dx, mBezierControl1.dy, mBezierEnd1.dx, mBezierEnd1.dy);
//     mTopPagePath.lineTo(mTouch.dx, mTouch.dy);
//     mTopPagePath.lineTo(mBezierEnd2.dx, mBezierEnd2.dy);
//     mTopPagePath.quadraticBezierTo(
//         mBezierControl2.dx, mBezierControl2.dy, mBezierStart2.dx, mBezierStart2.dy);
//     mTopPagePath.lineTo(mCornerX, mCornerY == 0 ? currentSize.height : 0);
//     mTopPagePath.lineTo(
//         mCornerX == 0 ? currentSize.width : 0, mCornerY == 0 ? currentSize.height : 0);
//     mTopPagePath.close();

//     /// 去掉PATH圈在屏幕外的区域，减少GPU使用
//     mTopPagePath = Path.combine(
//         PathOperation.intersect,
//         Path()
//           ..moveTo(0, 0)
//           ..lineTo(currentSize.width, 0)
//           ..lineTo(currentSize.width, currentSize.height)
//           ..lineTo(0, currentSize.height)
//           ..close(),
//         mTopPagePath);

//     canvas.save();

// //    canvas.drawImageRect(
// //        readerViewModel.getCurrentPage().pageImage,
// //        Offset.zero & currentSize,
// //        Offset.zero & currentSize,
// //        Paint()..isAntiAlias = true);
//     canvas.clipRect(Rect.fromLTWH(0, 0, mTouch.dx + 10, currentSize.height));
//     canvas.drawPicture(picture);

//     drawTopPageShadow(canvas, mTouch, currentSize);

//     canvas.restore();
//   }

//   /// 画顶部页的阴影 ///
//   void drawTopPageShadow(Canvas canvas, Offset mTouch, Size currentSize) {
//     Path shadowPath = Path();

//     int dx = mCornerX == 0 ? 5 : -5;
//     int dy = mCornerY == 0 ? 5 : -5;

//     shadowPath = Path.combine(
//         PathOperation.intersect,
//         Path()
//           ..moveTo(0, 0)
//           ..lineTo(currentSize.width, 0)
//           ..lineTo(currentSize.width, currentSize.height)
//           ..lineTo(0, currentSize.height)
//           ..close(),
//         Path()
//           ..moveTo(mTouch.dx + dx, mTouch.dy + dy)
//           ..lineTo(mBezierControl2.dx + dx, mBezierControl2.dy + dy)
//           ..lineTo(mBezierControl1.dx + dx, mBezierControl1.dy + dy)
//           ..close());

//     canvas.drawShadow(shadowPath, Colors.black, 5, true);
//   }

//   /// 画底下那页的阴影 ///
//   void drawBottomPageShadow(Canvas canvas, ui.Picture picture) {
//     double left;
//     double right;

//     Gradient shadowGradient;
//     if (mIsRTandLB) {
//       //左下及右上
//       left = 0;
//       right = mTouchToCornerDis / 4;

//       shadowGradient = new LinearGradient(
//         colors: [
//           Color(0xAA000000),
//           Colors.transparent,
//         ],
//       );
//     } else {
//       left = -mTouchToCornerDis / 4;
//       right = 0;

//       shadowGradient = new LinearGradient(
//         colors: [
//           Colors.transparent,
//           Color(0xAA000000),
//         ],
//       );
//     }

//     canvas.translate(mBezierStart1.dx, mBezierStart1.dy);
//     canvas
//         .rotate(math.atan2(mBezierControl1.dx - mCornerX, mBezierControl2.dy - mCornerY));

//     var shadowPaint = Paint()
//       ..isAntiAlias = false
//       ..style = PaintingStyle.fill //填充
//       ..shader = shadowGradient.createShader(Rect.fromLTRB(left, 0, right, mMaxLength));

//     canvas.drawRect(Rect.fromLTRB(left, 0, right, mMaxLength), shadowPaint);
//   }

//   /// 画在最顶上的那页的翻转过来的部分 ///
//   /// 仿真翻页中性能损失最大的部分，注释掉drawTopPageBackArea能保证绘制会在16ms以内，但是去掉注释，部分情况甚至会到40+
//   /// 盲猜是过于复杂的图层处理导致的(Flutter的图层处理性能还是不如原生啊……但是好像图层绘制性能很强大，好像甚至优于原生)
//   void drawTopPageBackArea(
//       Canvas canvas, Offset mTouch, Size currentSize, ui.Picture picture) {
//     mBottomPagePath.reset();
//     mBottomPagePath.moveTo(mCornerX, mCornerY);
//     mBottomPagePath.lineTo(mBezierStart1.dx, mBezierStart1.dy);
//     mBottomPagePath.quadraticBezierTo(
//         mBezierControl1.dx, mBezierControl1.dy, mBezierEnd1.dx, mBezierEnd1.dy);
//     mBottomPagePath.lineTo(mTouch.dx, mTouch.dy);
//     mBottomPagePath.lineTo(mBezierEnd2.dx, mBezierEnd2.dy);
//     mBottomPagePath.quadraticBezierTo(
//         mBezierControl2.dx, mBezierControl2.dy, mBezierStart2.dx, mBezierStart2.dy);
//     mBottomPagePath.close();

//     Path tempBackAreaPath = Path();

//     tempBackAreaPath.reset();
//     tempBackAreaPath.moveTo(mBezierVertex1.dx, mBezierVertex1.dy);
//     tempBackAreaPath.lineTo(mBezierVertex2.dx, mBezierVertex2.dy);
//     tempBackAreaPath.lineTo(mTouch.dx, mTouch.dy);
//     tempBackAreaPath.close();

//     if (tempBackAreaPath == null || mBottomPagePath == null) {
//       return;
//     }

//     /// 取path 相交部分 ///
//     mTopBackAreaPagePath =
//         Path.combine(PathOperation.intersect, tempBackAreaPath, mBottomPagePath);

//     /// 去掉PATH圈在屏幕外的区域，减少GPU使用
//     mTopBackAreaPagePath = Path.combine(
//         PathOperation.intersect,
//         Path()
//           ..moveTo(0, 0)
//           ..lineTo(currentSize.width, 0)
//           ..lineTo(currentSize.width, currentSize.height)
//           ..lineTo(0, currentSize.height)
//           ..close(),
//         mTopBackAreaPagePath);

//     canvas.save();

//     canvas.clipPath(mTopBackAreaPagePath);
//     canvas.drawPaint(Paint()..color = config.backgroundColor);

//     canvas.save();

//     mTopBackAreaPagePath.getBounds();

//     canvas.translate(mBezierControl1.dx, mBezierControl1.dy);

//     /// 矩阵公式：α表示翻转页面和边的夹角
//     /// https://juejin.im/post/5a32ade0f265da43252954b2
//     ///
//     ///  -(1-2sin(a)^2 )   2sin(a)cos(a)   0
//     ///  2sin(a)cos(a)      1-2sin(a)^2    0
//     ///  0                0             1

//     double dis = math.sqrt(math.pow((mCornerX - mBezierControl1.dx), 2) +
//         math.pow((mBezierControl2.dy - mCornerY), 2));
//     double sinAngle = (mCornerX - mBezierControl1.dx) / dis;
//     double cosAngle = (mBezierControl2.dy - mCornerY) / dis;

//     Matrix4 matrix4 = Matrix4.columns(
//         v.Vector4(-(1 - 2 * sinAngle * sinAngle), 2 * sinAngle * cosAngle, 0, 0),
//         v.Vector4(2 * sinAngle * cosAngle, (1 - 2 * sinAngle * sinAngle), 0, 0),
//         v.Vector4(0, 0, 1, 0),
//         v.Vector4(0, 0, 0, 1));

//     matrix4.translate(-mBezierControl1.dx, -mBezierControl1.dy);
//     canvas.transform(matrix4.storage);

//     /// 用image处理有奇效……原因未知，好像是picture是保存了绘制信息的原因，所以像这种n次平移->翻转->半透明图层叠加->裁剪->加阴影 的复杂操作处理不过来
//     /// image相对简单，就是张图片，处理了就处理了，不会留下需要保存的信息
//     /// 反正是一个半透明处理的，所以对清晰度没要求，所以这里用image绘制
//     /// 我个人的猜测……求精通底层的大佬解惑
//     // if (image != null)
//     //   canvas.drawImageRect(image!, Offset.zero & currentSize, Offset.zero & currentSize,
//     //       Paint()..isAntiAlias = true);
// //    canvas.drawImage(configManager.currentPageImage, Offset.zero, Paint()..isAntiAlias=true);
//     canvas.drawPicture(picture);
// //    canvas.drawPaint(Paint()..color = Color(0xCCFFFFFF));
// //    canvas.drawPaint(Paint()..color =Colors.blue);
//     canvas.drawPaint(Paint()..color = Color(config.backgroundColor.value & 0xAAFFFFFF));
// //    canvas.drawPaint(Paint()..color = Color(0xAAfff2cc));

//     canvas.restore();

//     drawTopPageBackAreaShadow(canvas);

//     canvas.restore();
//   }

//   /// 画翻起页的阴影 ///
//   void drawTopPageBackAreaShadow(Canvas canvas) {
//     double i = (mBezierStart1.dx + mBezierControl1.dx) / 2;
//     double f1 = (i - mBezierControl1.dx).abs();
//     double i1 = (mBezierStart2.dy + mBezierControl2.dy) / 2;
//     double f2 = (i1 - mBezierControl2.dy).abs();
//     double f3 = math.min(f1, f2);

//     double left;
//     double right;
//     double width;
//     if (mIsRTandLB) {
//       left = (mBezierStart1.dx - 1);
//       right = (mBezierStart1.dx + f3 + 1);
//       width = right - left;
//     } else {
//       left = (mBezierStart1.dx - f3 - 1);
//       right = (mBezierStart1.dx + 1);
//       width = left - right;
//     }

//     canvas.translate(mBezierStart1.dx, mBezierStart1.dy);
//     canvas
//         .rotate(math.atan2(mBezierControl1.dx - mCornerX, mBezierControl2.dy - mCornerY));

//     Gradient shadowGradient = new LinearGradient(
//       colors: [
//         Colors.transparent,
//         Color(0xAA000000),
//       ],
//     );

//     var shadowPaint = Paint()
//       ..isAntiAlias = true
//       ..style = PaintingStyle.fill //填充
//       ..shader = shadowGradient.createShader(Rect.fromLTRB(0, 0, width, mMaxLength));

//     canvas.drawRect(Rect.fromLTRB(0, 0, width, mMaxLength), shadowPaint);
//   }
// }
