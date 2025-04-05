import 'package:flutter/material.dart';

import 'ui_colors.dart';

const String _defaultFontFamily = "CreatoDisplay";
const Color _defaultFontColor = cBlack;
const double _defaultFontSize = 16;
const Map<int, FontWeight> _fontWeightMap = {
  100: FontWeight.w100,
  200: FontWeight.w200,
  300: FontWeight.w300,
  400: FontWeight.w400,
  500: FontWeight.w500,
  600: FontWeight.w600,
  700: FontWeight.w700,
  800: FontWeight.w800,
  900: FontWeight.w900,
};
const FontStyle _defaultFontStyle = FontStyle.normal;
const TextDecoration _defaultTextDecoration = TextDecoration.none;
const double defaultStrokeWidth = 2;
const Color defaultOutlineColor = cWhite;

List<Shadow> _defaultOutline([
  double strokeWidth = defaultStrokeWidth,
  Color colorOutline = defaultOutlineColor,
]) {
  return [
    Shadow(offset: Offset(-strokeWidth, -strokeWidth), color: colorOutline),
    Shadow(offset: Offset(strokeWidth, -strokeWidth), color: colorOutline),
    Shadow(offset: Offset(strokeWidth, strokeWidth), color: colorOutline),
    Shadow(offset: Offset(-strokeWidth, strokeWidth), color: colorOutline),
  ];
}

FontWeight _getFontWeight(int weight) {
  return _fontWeightMap[weight] ?? FontWeight.normal;
}

TextStyle _buildTextStyle(
  Color color,
  double fontSize,
  int fontWeight,
  String fontFamily,
  bool useItalic,
  bool useUnderline,
  bool useOutline,
) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: _getFontWeight(fontWeight),
    fontFamily: fontFamily,
    fontStyle: useItalic ? FontStyle.italic : _defaultFontStyle,
    decoration:
        useUnderline ? TextDecoration.underline : _defaultTextDecoration,
    decorationColor: useUnderline ? color : null,
    shadows: useOutline ? _defaultOutline() : null,
  );
}

TextStyle defaultTextStyle() {
  return _buildTextStyle(
    _defaultFontColor,
    _defaultFontSize,
    400,
    _defaultFontFamily,
    false,
    false,
    false,
  );
}

TextStyle styleByNumber(
  int fontWeight, {
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    fontWeight,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleThin([
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
]) {
  return _buildTextStyle(
    color,
    fontSize,
    100,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleExtraLight([
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
]) {
  return _buildTextStyle(
    color,
    fontSize,
    200,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleLight({
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    300,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleRegular({
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    400,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleMedium({
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    500,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleSemiBold({
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    600,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleBold({
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    700,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleExtraBold({
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    800,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}

TextStyle styleBlack({
  double fontSize = _defaultFontSize,
  Color color = _defaultFontColor,
  String fontFamily = _defaultFontFamily,
  bool useItalic = false,
  bool useUnderline = false,
  bool useOutline = false,
}) {
  return _buildTextStyle(
    color,
    fontSize,
    900,
    fontFamily,
    useItalic,
    useUnderline,
    useOutline,
  );
}
