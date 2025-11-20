import 'package:flutter/material.dart';

class ScoreColor {
  final Map<String, Color> excellent = {
    "background": Color.fromARGB(255, 205, 245, 205),
    "border": Color.fromARGB(255, 147, 249, 147),
    "text": Color.fromARGB(255, 4, 119, 4),
  };

  final Map<String, Color> good = {
    "background": Color.fromARGB(255, 251, 244, 205),
    "border": Color.fromARGB(255, 249, 229, 147),
    "text": Color.fromARGB(255, 216, 119, 4),
  };

  final Map<String, Color> fair = {
    "background": Color.fromARGB(255, 255, 235, 205),
    "border": Color.fromARGB(255, 255, 200, 147),
    "text": Color.fromARGB(255, 204, 85, 0),
  };

  final Map<String, Color> poor = {
    "background": Color.fromARGB(255, 255, 205, 205),
    "border": Color.fromARGB(255, 249, 147, 147),
    "text": Color.fromARGB(255, 170, 0, 0),
  };

  final Map<String, Color> veryBad = {
    "background": Color.fromARGB(255, 205, 205, 205),
    "border": Color.fromARGB(255, 147, 147, 147),
    "text": Color.fromARGB(255, 50, 50, 50),
  };
}
