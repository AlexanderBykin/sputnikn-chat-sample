import 'package:flutter/material.dart';

class Palette {
  Palette._();

  static Color roomAvatarBGColor = const Color(0xFF212249);
  static const color0 = Color(0xFF212249);
  static const color1 = Color(0xFF404791);
  static const color2 = Color(0xFFE2E2E2);
  static const color3 = Color(0xFFBAE0CE);
  static const color4 = Color(0xFF635FF6);
  static const color5 = Color(0xFFE5E3FC);
  static const color6 = Color(0xFF9790CC);


  static final primarySwatch = MaterialColor(
    Palette.color0.value,
    const {
      50: Palette.color0, //10%
      100: Palette.color0, //20%
      200: Palette.color0, //30%
      300: Palette.color0, //40%
      400: Palette.color0, //50%
      500: Palette.color0, //60%
      600: Palette.color0, //70%
      700: Palette.color0, //80%
      800: Palette.color0, //90%
      900: Palette.color0, //100%
    },
  );
}
