import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'text_composition.dart';

class TextCompositionEffect extends CustomPainter {
  TextCompositionEffect({
    required this.amount,
    required this.index,
    required this.textComposition,
    this.radius = 0.18,
  }) : super(repaint: amount);

  final Animation<double> amount;
  ui.Image? image;
  bool? toImageIng;
  final double radius;
  final int index;
  final TextComposition textComposition;

  /// 原始动效
  void paintCurl(ui.Canvas canvas, ui.Size size, double pos, ui.Image image,
      Color? backgroundColor) {
    final movX = (1.0 - pos) * 0.85;
    final calcR = (movX < 0.20) ? radius * movX * 5 : radius;
    final wHRatio = 1 - calcR;
    final hWRatio = image.height / image.width;
    final hWCorrection = (hWRatio - 1.0) / 2.0;

    final w = size.width.toDouble();
    final h = size.height.toDouble();
    final c = canvas;
    final shadowXf = (wHRatio - movX);
    final shadowSigma = Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - shadowXf)));
    final pageRect = Rect.fromLTRB(0.0, 0.0, w * shadowXf, h);
    if (backgroundColor != null) {
      c.drawRect(pageRect, Paint()..color = backgroundColor);
    }
    if (pos != 0) {
      c.drawRect(
        pageRect,
        Paint()
          ..color = Colors.black54
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
      );
    }

    final ip = Paint();
    for (double x = 0; x < size.width; x++) {
      final xf = (x / w);
      final v = (calcR * (math.sin(math.pi / 0.5 * (xf - (1.0 - pos)))) + (calcR * 1.1));
      final xv = (xf * wHRatio) - movX;
      if (xv < 0) continue;
      final sx = (xf * image.width);
      final sr = Rect.fromLTRB(sx, 0.0, sx + 1.0, image.height.toDouble());
      final yv = ((h * calcR * movX) * hWRatio) - hWCorrection;
      final ds = (yv * v);
      final dr = Rect.fromLTRB(xv * w, 0.0 - ds, xv * w + 1.0, h + ds);
      c.drawImageRect(image, sr, dr, ip);
      // canvas.save();
      // canvas.clipRect(dr);
      // canvas.transform((Matrix4.diagonal3Values(1, 1 + 2 * ds / h, 1)
      //       ..translate(xv * w - sx, -ds, 0))
      //     .storage);
      // canvas.drawPicture(picture);
      // canvas.restore();
    }
  }

  @override
  bool shouldRepaint(TextCompositionEffect oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.amount.value != amount.value ||
        index != oldDelegate.index;
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (index > textComposition.currentIndex + 2 ||
        index < textComposition.currentIndex - 2 ||
        index < textComposition.firstIndex ||
        index > textComposition.lastIndex) {
      return;
    }

    final picture = textComposition.getPicture(index, size);
    if (picture == null) {
      // 画正好加载最后章节
      return;
    }

    if (textComposition.animation == 'curl' && image == null && toImageIng != true) {
      toImageIng = true;
      picture.toImage(size.width.round(), size.height.round()).then((value) {
        image = value;
        toImageIng = false;
      });
    }

    /// 这里开始画，先判断上一页 在画当前页
    /// 如果上一页还有东西 直接裁剪或者不画 也许会节约资源??
    /// 即便出问题 有时候少一帧 大概没影响??
    if (textComposition.getAnimationPostion(index - 1) > 0.998) {
      return;
    }

    if (textComposition.shouldClipStatus) {
      canvas.clipRect(Rect.fromLTRB(0, ui.window.padding.top / ui.window.devicePixelRatio,
          size.width, size.height));
    }

    final pos = amount.value; // 1 / 500 = 0.002 也就是500宽度相差1像素 忽略掉动画
    if (pos > 0.998) {
      canvas.drawPicture(picture);
    } else if (pos < 0.002) {
      return;
    } else {
      switch (textComposition.animation) {
        case 'curl':
          if (image == null) {
            if (toImageIng == true) return;
            toImageIng = true;
            picture.toImage(size.width.round(), size.height.round()).then((value) {
              image = value;
              toImageIng = false;
            });
          } else {
            paintCurl(canvas, size, pos, image!, textComposition.backgroundColor);
          }
          break;

        case 'cover':
          final right = pos * size.width;
          final shadowSigma = Shadow.convertRadiusToSigma(16);
          final pageRect = Rect.fromLTRB(0.0, 0.0, right, size.height);
          canvas.drawRect(
            pageRect,
            Paint()
              ..color = Colors.black54
              ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
          );
          canvas.translate(right - size.width, 0);
          canvas.drawPicture(picture);
          break;

        case 'flip':
          if (pos > 0.5) {
            canvas.drawPicture(picture);
            canvas.clipRect(Rect.fromLTRB(size.width / 2, 0, size.width, size.height));
            () {
              final nextPicture = textComposition.getPicture(index + 1, size);
              if (nextPicture == null) return;
              canvas.drawPicture(nextPicture);
            }();
            canvas.transform((Matrix4.identity()
                  ..setEntry(3, 2, 0.0005)
                  ..translate(size.width / 2, 0, 0)
                  ..rotateY(math.pi * (1 - pos))
                  ..translate(-size.width / 2, 0, 0))
                .storage);
            canvas.drawRect(
              Offset.zero & size,
              Paint()
                ..color = Colors.black54
                ..maskFilter = MaskFilter.blur(BlurStyle.outer, 20),
            );
            canvas.drawPicture(picture);
          } else {
            final nextPicture = textComposition.getPicture(index + 1, size);
            if (nextPicture == null) return;
            canvas.drawPicture(nextPicture);
            canvas.clipRect(Rect.fromLTRB(0, 0, size.width / 2, size.height));
            canvas.drawPicture(picture);
            canvas.transform((Matrix4.identity()
                  ..setEntry(3, 2, 0.0005)
                  ..translate(size.width / 2, 0, 0)
                  ..rotateY(-math.pi * pos)
                  ..translate(-size.width / 2, 0, 0))
                .storage);
            canvas.drawRect(
              Offset.zero & size,
              Paint()
                ..color = Colors.black54
                ..maskFilter = MaskFilter.blur(BlurStyle.outer, 20),
            );
            canvas.drawPicture(nextPicture);
          }
          break;

        case 'simulation':
          final w = size.width;
          final h = size.height;
          final right = pos * w;
          final left = 2 * right - w;
          canvas.save();
          canvas.clipRect(Rect.fromLTRB(0, 0, left, h));
          canvas.drawPicture(picture);
          // 左侧阴影
          final shadow = Path()
            ..moveTo(left - 3, 0)
            ..lineTo(left + 2, 0)
            ..lineTo(left + 2, h)
            ..lineTo(left - 3, h)
            ..close();
          canvas.drawShadow(shadow, Colors.black, 5, true);
          canvas.restore();
          // 背面
          canvas.clipRect(Rect.fromLTRB(left, 0, right, h));
          canvas.transform(
              (Matrix4.rotationY(-math.pi)..translate(-2 * right, 0, 0)).storage);
          canvas.drawPicture(picture);
          canvas.drawPaint(
              Paint()..color = Color(textComposition.backgroundColor.value & 0x88FFFFFF));
          // 背面阴影
          Gradient shadowGradient =
              LinearGradient(colors: [Color(0xAA000000), Colors.transparent]);
          final shadowRect =
              Rect.fromLTRB(right, 0, right + math.min((w - right) * 0.5, 30), h);
          var shadowPaint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill //填充
            ..shader = shadowGradient.createShader(shadowRect);
          canvas.drawRect(shadowRect, shadowPaint);
          break;
        default:
      }
    }
  }
}
