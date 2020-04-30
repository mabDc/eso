/*
 * @Author: Nelson 
 * @Date: 2019-12-19 14:58:46 
 * @Last Modified by: Nelson
 * @Last Modified time: 2020-03-30 14:57:27
 */

import 'dart:ui';
import 'package:flutter/material.dart';

class AdaptUtil {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static double _width = mediaQuery.size.width;
  static double _height = mediaQuery.size.height;
  static double _devicePixelRatio = mediaQuery.devicePixelRatio;
  static var _zoom;

  static double get width => _width;

  static double get height => _height;

  static init() {
    double designWidth = 750.0;
    _zoom = _width * _devicePixelRatio / designWidth;
    print('AdaptUtil, width * height:' + width.toString() + '*' +
        height.toString());
    print('AdaptUtil, Device Pixel RADIO:' + _devicePixelRatio.toString());
    print('AdaptUtil, RADIO:' + _zoom.toString());
  }

  static double adaptSize(double pt) {
    if (_zoom == null) {
      AdaptUtil.init();
    }
    return pt * _zoom;
  }

  static double originSize(double pt) {
    return pt;
  }
}