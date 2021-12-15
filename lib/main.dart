import 'dart:async';
import 'package:sputnikn_chatsample/di/app_config.dart';
import 'package:sputnikn_chatsample/di/di.dart';
import 'package:sputnikn_chatsample/main_app.dart';
import 'package:flutter/widgets.dart';

void main() {
  runZonedGuarded(
    () async {
      await DI.setup(AppConfig(
        "http://192.168.0.101:8443/",
        "ws://192.168.0.101:8443/chat",
      ));
      runApp(MainApp());
    },
    (error, stack) {
      debugPrint("$error\n$stack", wrapWidth: 1000);
    },
  );
}
