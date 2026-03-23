import 'package:flutter/material.dart';

class ScrollRequest {
  final double? xOffset; // Null means don't scroll horizontally
  final double? yOffset; // Null means don't scroll vertically
  final Duration duration;
  final Curve curve;

  const ScrollRequest({
    this.xOffset,
    this.yOffset,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });
}