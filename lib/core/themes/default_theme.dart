import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/core/themes/palette.dart';

class Themes {
  Themes._();

  static TextStyle get defaultTextStyle => const TextStyle(
        color: Palette.color5,
        fontFamily: 'Roboto',
        decorationThickness: 0.000001,
      );

  static ButtonStyle get defaultButtonStyle => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Palette.color4),
        foregroundColor: MaterialStateProperty.all(Palette.color5),
      );

  static ThemeData get appTheme {
    return ThemeData.from(
      colorScheme: const ColorScheme.dark(
        primary: Palette.color0,
        secondary: Palette.color5,
        background: Palette.color0,
      ),
      textTheme: TextTheme(
        bodyLarge: defaultTextStyle,
        bodyMedium: defaultTextStyle,
        displayLarge: defaultTextStyle,
        displayMedium: defaultTextStyle,
        displaySmall: defaultTextStyle,
        headlineMedium: defaultTextStyle,
        headlineSmall: defaultTextStyle,
        titleLarge: defaultTextStyle,
        titleMedium: defaultTextStyle,
        titleSmall: defaultTextStyle,
        bodySmall: defaultTextStyle,
      ),
    ).copyWith(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Palette.color5,
        selectionColor: Palette.color5,
      ),
      textButtonTheme: TextButtonThemeData(
        style: defaultButtonStyle,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Palette.color0,
      ),
    );
  }
}
