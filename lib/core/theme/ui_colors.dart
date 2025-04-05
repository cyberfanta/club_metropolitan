import 'dart:ui';

import '../../utils/linear_interpolation.dart';

const cBackground = cGray;

const cTransparent = Color.fromRGBO(0, 0, 0, 0);
const cGreenTransparent = Color.fromRGBO(239, 241, 237, 1);

const cWhite = Color.fromRGBO(255, 255, 255, 1);
const cBlack = Color.fromRGBO(30, 30, 30, 1);
const cFullBlack = Color.fromRGBO(0, 0, 0, 1);

const cRed = Color.fromRGBO(255, 0, 0, 1);
const cRedError = Color.fromRGBO(218, 45, 45, 1);

const cGreen = Color.fromRGBO(0, 145, 0, 1);
const cGold = Color(0xFFA99A86);

const cGray = Color.fromRGBO(205, 205, 205, 1);
const cLightRed = Color.fromRGBO(235, 87, 87, 1);
const cBlue = Color.fromRGBO(47, 128, 237, 1);
const cBlueClickable = Color.fromRGBO(75, 143, 252, 1);

const cPink = Color.fromRGBO(249, 209, 227, 1);
const cWeedGreen = Color.fromRGBO(200, 217, 46, 1);
const cCyan = Color.fromRGBO(6, 206, 200, 1);
const cMagenta = Color.fromRGBO(202, 0, 136, 1);
const cPurple = Color.fromRGBO(144, 26, 139, 1);
const cYellow = Color.fromRGBO(251, 255, 78, 1);

const cCream = Color.fromRGBO(255, 240, 201, 1);
const cDarkBlue = Color.fromRGBO(34, 19, 68, 1);
const cLightBlue = Color.fromRGBO(10, 249, 242, 1);

Color adjustOpacity(Color color, double opacity) {
  double red = color.r;
  double green = color.g;
  double blue = color.b;

  return Color.fromRGBO(
    freeInterpolate(red, 0, 1, 0, 255).toInt(),
    freeInterpolate(green, 0, 1, 0, 255).toInt(),
    freeInterpolate(blue, 0, 1, 0, 255).toInt(),
    opacity,
  );
}
