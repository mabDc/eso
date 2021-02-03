import 'package:flutter/material.dart';

class MenuItem<T> {
  final T value;
  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;

  const MenuItem({
    this.value,
    this.text,
    this.icon,
    this.color,
    this.textColor,
  });
}
