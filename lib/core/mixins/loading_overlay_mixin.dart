import 'package:flutter/material.dart';

/// Loading overlay mixin for screens
/// Discussion here: https://github.com/felangel/bloc/issues/1919
mixin LoadingOverlayMixin {
  OverlayEntry? _overlay;

  void showLoader(BuildContext context) {
    if (_overlay == null) {
      _overlay = OverlayEntry(
        // replace with your own layout
        builder: (context) => const ColoredBox(
          color: Color(0x80000000),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
      );
      Overlay.of(context)?.insert(_overlay!);
    }
  }

  void hideLoader() {
    _overlay?.remove();
    _overlay = null;
  }
}
