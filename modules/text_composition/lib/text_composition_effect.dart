import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'text_composition.dart';

class TextCompositionEffect extends CustomPainter {
  TextCompositionEffect({
    required this.amount,
    required this.index,
    required this.config,
    required this.textComposition,
    this.radius = 0.18,
  }) : super(repaint: amount);

  final Animation<double> amount;
  ui.Image? image;
  bool? drawing;
  ui.Picture? picture;
  final double radius;
  final int index;
  final TextCompositionConfig config;
  final TextComposition textComposition;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final textPage = textComposition.textPages[index];
    if (textPage == null) {
      // 画正好加载最后章节
      return;
    }
    if (index > textComposition.currentIndex + 1) return;
    if (index < textComposition.currentIndex - 1) return;

    final pos = amount.value;
    if (pos < 0.004) return;
    if (image == null && drawing != true) {
      drawing = true;
      final pic = ui.PictureRecorder();
      final c = Canvas(pic);
      // c.scale(ui.window.devicePixelRatio);
      final shadowSigma = Shadow.convertRadiusToSigma(8.0);
      final pageRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
      c.drawRect(pageRect, Paint()..color = config.backgroundColor);
      c.drawRect(
        pageRect,
        Paint()
          ..color = Colors.black54
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
      );
      paintText(c, size, textPage, config);
      picture = pic.endRecording();
      picture!.toImage(size.width.round(), size.height.round())
          // .toImage(ui.window.physicalSize.width.round(), ui.window.physicalSize.height.round())
          .then((value) {
        image = value;
        drawing = false;
      });
      if (pos > 0.996) {
        canvas.drawPicture(picture!);
      }
      return;
    }

    if (pos > 0.996) {
      if (picture != null) {
        canvas.drawPicture(picture!);
      }
      return;
    }

    final posP = pos * size.width;
    if (config.animation == 'cover') {
      canvas.translate(posP - size.width, 0);
      canvas.drawPicture(picture!);
    } else if (config.animation == 'curl') {
      final movX = (1.0 - pos) * 0.85;
      final calcR = (movX < 0.20) ? radius * movX * 5 : radius;
      final wHRatio = 1 - calcR;
      final hWRatio = image!.height / image!.width;
      final hWCorrection = (hWRatio - 1.0) / 2.0;

      final w = size.width.toDouble();
      final h = size.height.toDouble();
      final c = canvas;
      final shadowXf = (wHRatio - movX);
      final shadowSigma = Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - shadowXf)));
      final pageRect = Rect.fromLTRB(0.0, 0.0, w * shadowXf, h);
      c.drawRect(pageRect, Paint()..color = config.backgroundColor);
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
        final v =
            (calcR * (math.sin(math.pi / 0.5 * (xf - (1.0 - pos)))) + (calcR * 1.1));
        final xv = (xf * wHRatio) - movX;
        final sx = (xf * image!.width);
        final sr = Rect.fromLTRB(sx, 0.0, sx + 1.0, image!.height.toDouble());
        final yv = ((h * calcR * movX) * hWRatio) - hWCorrection;
        final ds = (yv * v);
        final dr = Rect.fromLTRB(xv * w, 0.0 - ds, xv * w + 1.0, h + ds);
        c.drawImageRect(image!, sr, dr, ip);
      }
    }
  }

  @override
  bool shouldRepaint(TextCompositionEffect oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.picture != picture ||
        oldDelegate.amount.value != amount.value ||
        index != oldDelegate.index;
  }
}
