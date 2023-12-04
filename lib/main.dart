import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sputnikn_chatsample/app/app.dart';
import 'package:sputnikn_chatsample/app/app_di.dart';
import 'package:sputnikn_chatsample/bootstrap.dart';
import 'package:sputnikn_chatsample/core/core.dart';

void main() {
  const appConfig = AppConfig(
    serverMediaUrl: 'http://192.168.1.2:8443/',
    serverChatWsUrl: 'ws://192.168.1.2:8443/chat',
  );

  bootstrap(
    () async {
      final providers = await AppDI.buildRepositoryProviders(appConfig);
      return MultiRepositoryProvider(
        providers: providers,
        child: const MainApp(),
      );
    },
  );
}
