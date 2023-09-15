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
      ui.Color? backgroundColor, ui.Image? backImage) {
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
    if (backImage != null) {
      c.drawImageRect(backImage, pageRect, pageRect, Paint());
    } else if (backgroundColor != null) {
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

  static bool autoVerticalDrag = false;

  drawBackImage(ui.Canvas canvas, bool withImage, [Rect? rect]) {
    if (withImage != textComposition.animationWithImage) return;
    final backImage = textComposition.backImage;
    if (backImage == null) {
      if (rect != null) {
        canvas.drawRect(rect, Paint()..color = textComposition.backgroundColor);
      } else {
        canvas.drawPaint(Paint()..color = textComposition.backgroundColor);
      }
    } else {
      if (rect != null) {
        canvas.drawImageRect(backImage, rect, rect, Paint());
      } else {
        canvas.drawImage(backImage, Offset.zero, Paint());
      }
    }
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

    if (textComposition.animation == AnimationType.curl &&
        image == null &&
        toImageIng != true) {
      toImageIng = true;
      toImage(picture, size);
    }

    /// 这里开始画，先判断上一页 在画当前页
    /// 如果上一页还有东西 直接裁剪或者不画 也许会节约资源??
    /// 即便出问题 有时候少一帧 大概没影响??
    if (textComposition.getAnimationPostion(index - 1) > 0.998) {
      drawBackImage(canvas, textComposition.animationWithImage);
      return;
    }

    if (textComposition.shouldClipStatus) {
      canvas.clipRect(Rect.fromLTRB(0, ui.window.padding.top / ui.window.devicePixelRatio,
          size.width, size.height));
    }

    final pos = amount.value; // 1 / 500 = 0.002 也就是500宽度相差1像素 忽略掉动画
    if (pos > 0.998) {
      canvas.drawPicture(picture);
      // if (textComposition.config.columns == 2 || (textComposition.config.columns == 0 && size.width > 580)) {
      //   // 中间阴影
      //   drawMiddleShadow(canvas, size);
      // }
      // 中间阴影应该在textpaint时候画
    } else if (pos < 0.002) {
      return;
    } else {
      switch (textComposition.animation) {
        case AnimationType.curl:
          if (image == null) {
            if (toImageIng == true) return;
            toImageIng = true;
            toImage(picture, size);
          } else {
            paintCurl(canvas, size, pos, image!, textComposition.backgroundColor,
                textComposition.backImage);
          }
          break;

        case AnimationType.coverHorizontal:
          final offset = pos * size.width;
          final shadowSigma = Shadow.convertRadiusToSigma(16);
          final pageRect = Rect.fromLTRB(0.0, 0.0, offset, size.height);
          drawBackImage(canvas, false, pageRect);
          canvas.drawRect(
            pageRect,
            Paint()
              ..color = Colors.black54
              ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
          );
          canvas.translate(offset - size.width, 0);
          drawBackImage(canvas, true);
          canvas.drawPicture(picture);
          break;

        case AnimationType.coverVertical:
          final offset = pos * size.height;
          final shadowSigma = Shadow.convertRadiusToSigma(16);
          final pageRect = Rect.fromLTRB(0.0, 0.0, size.width, offset);
          drawBackImage(canvas, false, pageRect);
          canvas.drawRect(
            pageRect,
            Paint()
              ..color = Colors.black54
              ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
          );
          canvas.translate(0, offset - size.height);
          drawBackImage(canvas, true);
          canvas.drawPicture(picture);
          break;

        case AnimationType.cover:
          final offset = autoVerticalDrag ? (pos * size.height) : (pos * size.width);
          final shadowSigma = Shadow.convertRadiusToSigma(16);
          final pageRect = autoVerticalDrag
              ? Rect.fromLTRB(0.0, 0.0, size.width, offset)
              : Rect.fromLTRB(0.0, 0.0, offset, size.height);
          drawBackImage(canvas, false, pageRect);
          canvas.drawRect(
            pageRect,
            Paint()
              ..color = Colors.black54
              ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
          );
          if (autoVerticalDrag) {
            canvas.translate(0, offset - size.height);
          } else {
            canvas.translate(offset - size.width, 0);
          }
          drawBackImage(canvas, true);
          canvas.drawPicture(picture);
          break;

        case AnimationType.slideHorizontal:
          final offset = pos * size.width;
          drawBackImage(canvas, false);
          canvas.translate(offset - size.width, 0);
          drawBackImage(canvas, true);
          canvas.drawPicture(picture);
          // 绘制下一页
          final nextPicture = textComposition.getPicture(index + 1, size);
          if (nextPicture == null) return;
          canvas.translate(size.width, 0);
          drawBackImage(canvas, true);
          canvas.drawPicture(nextPicture);
          break;

        case AnimationType.slideVertical:
          final offset = pos * size.height;
          drawBackImage(canvas, false);
          canvas.translate(0, offset - size.height);
          drawBackImage(canvas, true);
          canvas.drawPicture(picture);
          // 绘制下一页
          final nextPicture = textComposition.getPicture(index + 1, size);
          if (nextPicture == null) return;
          canvas.translate(0, size.height);
          drawBackImage(canvas, true);
          canvas.drawPicture(nextPicture);
          break;

        case AnimationType.slide:
          final offset = autoVerticalDrag ? (pos * size.height) : (pos * size.width);
          drawBackImage(canvas, false);
          if (autoVerticalDrag) {
            canvas.translate(0, offset - size.height);
          } else {
            canvas.translate(offset - size.width, 0);
          }
          drawBackImage(canvas, true);
          canvas.drawPicture(picture);
          // 绘制下一页
          final nextPicture = textComposition.getPicture(index + 1, size);
          if (nextPicture == null) return;
          if (autoVerticalDrag) {
            canvas.translate(0, size.height);
          } else {
            canvas.translate(size.width, 0);
          }
          drawBackImage(canvas, true);
          canvas.drawPicture(nextPicture);
          break;

        case AnimationType.scroll:
          drawBackImage(canvas, textComposition.animationWithImage);
          canvas.translate(
              0,
              pos * size.height -
                  size.height +
                  (textComposition.isForward == true ? 0 : 50));
          canvas.save();
          canvas.clipRect(Rect.fromLTRB(
              0, textComposition.config.topPadding + 1, size.width, size.height - 30));
          canvas.drawPicture(picture);
          canvas.restore();
          // 绘制下一页
          final nextPicture = textComposition.getPicture(index + 1, size);
          if (nextPicture == null) return;
          canvas.translate(0, size.height - 50);
          canvas.clipRect(Rect.fromLTRB(
              0, textComposition.config.topPadding + 1, size.width, size.height));
          canvas.drawPicture(nextPicture);
          break;

        case AnimationType.flip:
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

        case AnimationType.simulation:
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
          canvas.drawPaint(Paint()..color = Color(0x22FFFFFF));
          // 背面阴影
          Gradient shadowGradient =
              LinearGradient(colors: [Color(0xAA000000), Colors.transparent]);
          final shadowRect =
              Rect.fromLTRB(right, 0, right + math.min((w - right) * 0.5, 30), h);
          final shadowPaint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill //填充
            ..shader = shadowGradient.createShader(shadowRect);
          canvas.drawRect(shadowRect, shadowPaint);
          break;

        case AnimationType.simulation2L:
          final w = size.width;
          final h = size.height;
          final half = w / 2;
          final p = pos * w;
          final ws = (w - p) / 2;
          final left = half - ws;
          final right = half + ws;
          // 阴影
          final shadowSigma = Shadow.convertRadiusToSigma(16);
          final pageRect = Rect.fromLTRB(left, 0, p, h);
          canvas.drawRect(
            pageRect,
            Paint()
              ..color = Colors.black54
              ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
          );
          // 左侧
          canvas.save();
          canvas.clipRect(Rect.fromLTRB(0, 0, left, h));
          canvas.drawPicture(picture);
          canvas.restore();
          // 右侧
          canvas.translate(p - w, 0);
          canvas.clipRect(Rect.fromLTRB(right, 0, w, h));
          canvas.drawPicture(picture);
          final Gradient shadowGradient =
              LinearGradient(colors: [Color(0x88000000), Colors.transparent]);
          final shadowRect = Rect.fromLTRB(right, 0, right + 10, h);
          var shadowPaint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill //填充
            ..shader = shadowGradient.createShader(shadowRect);
          canvas.drawRect(shadowRect, shadowPaint);
          break;

        case AnimationType.simulation2R:
          final w = size.width;
          final h = size.height;
          final left = pos * w;
          final ws = (w - left) / 2;
          final right = left + ws;
          canvas.save();
          canvas.clipRect(Rect.fromLTRB(0, 0, left, h));
          canvas.drawPicture(picture);
          // if (pos > 0.4) {
          //   // 中间阴影
          //   drawMiddleShadow(canvas, size);
          // }
          // 左侧阴影
          final shadow = Path()
            ..moveTo(left - 3, 0)
            ..lineTo(left + 2, 0)
            ..lineTo(left + 2, h)
            ..lineTo(left - 3, h)
            ..close();
          canvas.drawShadow(shadow, Colors.black, 5, true);
          canvas.restore();
          // 背面 也就是 下一页
          final nextPicture = textComposition.getPicture(index + 1, size);
          if (nextPicture == null) return;
          canvas.clipRect(Rect.fromLTRB(left, 0, right, h));
          canvas.translate(left, 0);
          canvas.drawPicture(nextPicture);
          // 背面阴影
          final Gradient shadowGradient =
              LinearGradient(colors: [Colors.transparent, Color(0x88000000)]);
          final shadowRect =
              Rect.fromLTRB(ws - math.min((w - right) * 0.5, 10), 0, ws, h);
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

  toImage(ui.Picture picture, ui.Size size) {
    if (textComposition.config.animationHighImage) {
      final r = ui.PictureRecorder();
      final size = ui.window.physicalSize;
      Canvas(r)
        ..scale(ui.window.devicePixelRatio)
        ..drawPicture(picture);
      r.endRecording().toImage(size.width.round(), size.height.round()).then((value) {
        image = value;
        toImageIng = false;
      });
    } else {
      picture.toImage(size.width.round(), size.height.round()).then((value) {
        image = value;
        toImageIng = false;
      });
    }
  }

  // drawMiddleShadow(Canvas canvas, ui.Size size) {
  //   final half = size.width / 2;
  //   final shadowGradientM = LinearGradient(colors: [
  //     Colors.transparent,
  //     Color(0x22000000),
  //     Color(0x66000000),
  //     Color(0x22000000),
  //     Colors.transparent
  //   ]);
  //   final shadowRectM = Rect.fromLTRB(half - 8, 0, half + 8, size.height);
  //   final shadowPaintM = Paint()
  //     ..isAntiAlias = true
  //     ..style = PaintingStyle.fill //填充
  //     ..shader = shadowGradientM.createShader(shadowRectM);
  //   canvas.drawRect(shadowRectM, shadowPaintM);
  // }
}

drawMiddleShadow(Canvas canvas, ui.Size size) {
  final half = size.width / 2;
  final shadowGradientM = LinearGradient(colors: [
    Colors.transparent,
    Color(0x22000000),
    Color(0x66000000),
    Color(0x22000000),
    Colors.transparent
  ]);
  final shadowRectM = Rect.fromLTRB(half - 8, 0, half + 8, size.height);
  final shadowPaintM = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill //填充
    ..shader = shadowGradientM.createShader(shadowRectM);
  canvas.drawRect(shadowRectM, shadowPaintM);
}
