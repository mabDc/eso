import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'text_composition.dart';

class TextCompositionEffect extends CustomPainter {
  TextCompositionEffect({
    required this.amount,
    required this.backgroundColor,
    required this.index,
    required this.config,
    required this.textComposition,
    this.radius = 0.18,
  }) : super(repaint: amount);

  final Animation<double> amount;
  ui.Image? image;
  bool? drawing;
  ui.Picture? picture;
  final Color backgroundColor;
  final double radius;
  final int index;
  final TextCompositionConfig config;
  final TextComposition textComposition;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final textPage = textComposition.textPages[index];
    if (textPage == null) {
      // 画加载最后章节
      return;
    }
    if (index > textComposition.currentIndex + 3) return;
    if (index < textComposition.currentIndex - 3) return;

    final pos = amount.value;

    if (image == null) {
      if (drawing == true) {
        if (pos > 0.996 && picture != null) canvas.drawPicture(picture!);
        return;
      }
      drawing = true;
      final pic = ui.PictureRecorder();
      final c = Canvas(pic);
      // c.scale(ui.window.devicePixelRatio);
      c.drawRect(Rect.fromLTRB(0.0, 0.0, size.width, size.height),
          Paint()..color = backgroundColor);
      paintText(c, size, textPage);
      picture = pic.endRecording();
      picture!.toImage(size.width.round(), size.height.round())
          // .toImage(ui.window.physicalSize.width.round(), ui.window.physicalSize.height.round())
          .then((value) {
        image = value;
        drawing = false;
      });
      if (pos > 0.996 && picture != null) canvas.drawPicture(picture!);
      return;
    }

    if (pos > 0.996) {
      if (picture != null) canvas.drawPicture(picture!);
      return;
    }

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
    if (pos != 0) {
      c.drawRect(
        pageRect,
        Paint()
          ..color = Colors.black54
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
      );
    }

    final ip = Paint();
    if (config.animation == 'curl') {
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
    } else if (config.animation == 'cover') {
      // final p = ui.window.devicePixelRatio;
      c.drawImageRect(
        image!,
        Rect.fromLTRB(0, 0.0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTRB(-size.width + w * shadowXf, 0.0, w * shadowXf, size.height),
        ip,
      );
    } else if (config.animation == 'curl2') {
      c.drawImageRect(image!, pageRect, pageRect, ip);
    }
  }

  void paintText(ui.Canvas canvas, ui.Size size, TextPage page) {
    print("paintText ${page.chIndex} ${page.number} / ${page.total}");
    final lineCount = page.lines.length;
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: config.fontSize,
      fontFamily: config.fontFamily,
      color: config.fontColor,
      height: config.fontHeight,
    );
    final style = TextStyle(
      fontSize: config.fontSize,
      fontFamily: config.fontFamily,
      color: config.fontColor,
      height: config.fontHeight,
    );
    for (var i = 0; i < lineCount; i++) {
      final line = page.lines[i];
      if (line.letterSpacing != null &&
          (line.letterSpacing! < -0.1 || line.letterSpacing! > 0.1)) {
        tp.text = TextSpan(
          text: line.text,
          style: line.isTitle
              ? TextStyle(
                  letterSpacing: line.letterSpacing,
                  fontWeight: FontWeight.bold,
                  fontSize: config.fontSize,
                  fontFamily: config.fontFamily,
                  color: config.fontColor,
                  height: config.fontHeight,
                )
              : TextStyle(
                  letterSpacing: line.letterSpacing,
                  fontSize: config.fontSize,
                  fontFamily: config.fontFamily,
                  color: config.fontColor,
                  height: config.fontHeight,
                ),
        );
      } else {
        tp.text = TextSpan(text: line.text, style: line.isTitle ? titleStyle : style);
      }
      final offset = Offset(line.dx, line.dy);
      tp.layout();
      tp.paint(canvas, offset);
    }
    final style2 = TextStyle(
      fontSize: 10,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );

    tp.text = TextSpan(text: page.info, style: style2);
    tp.layout(
      maxWidth: size.width - config.leftPadding - config.rightPadding - 100,
    );
    tp.paint(canvas, Offset(config.leftPadding, size.height - 24));

    tp.text = TextSpan(
      text: '${page.number}/${page.total} ${(100 * page.percent).toStringAsFixed(2)}%',
      style: style2,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(size.width - config.rightPadding - tp.width, size.height - 24),
    );
  }

  @override
  bool shouldRepaint(TextCompositionEffect oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.picture != picture ||
        oldDelegate.amount.value != amount.value ||
        index != oldDelegate.index;
  }
}
