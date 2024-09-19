import 'dart:developer' as dev;

import 'package:flutter/material.dart';

enum Logger {
  basic('29'),
  black('30'),
  red('31'),
  green('32'),
  yellow('33'),
  blue('34'),
  magenta('35'),
  cyan('36'),
  white('37');

  final String code;
  const Logger(this.code);

  Color get color {
    switch (this) {
      case black:
        return Colors.black;
      case red:
        return Colors.red;
      case green:
        return Colors.green;
      case yellow:
        return Colors.yellow;
      case blue:
        return Colors.blue;
      case magenta:
        return Colors.pink;
      case cyan:
        return Colors.cyan;
      case basic:
      case white:
        return Colors.white;
    }
  }

  String coloredText(dynamic text) => '\x1B[${code}m$text\x1B[0m';

  // void consoleDebugPrint(dynamic text) => debugPrint(coloredText(text));
  // void consolePrint(dynamic text) => print(coloredText(text));
  void log(dynamic text) => dev.log(coloredText(text));
}
