import 'package:flutter/material.dart';

class PVector {
  late double x, y;

  PVector(this.x, this.y);
}

enum ParticleType {
  TEXT,
  CIRCLE
}

class Particle {
  ParticleType type = ParticleType.CIRCLE;
  String text = "";
  PVector position = PVector(0.0, 0.0);
  PVector velocity = PVector(0.0, 0.0);
  double mass = 10.0; //kg
  double radius = 100 / 10; //1m = 100 px or pt (0.10 m)
  Color color = Colors.green;
  double area = 0.0314; //PI x r x r
  double jumpVector = -0.6;
}
