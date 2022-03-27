import 'dart:async';

import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sputnikn_chatsample/bootstrap.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocs = await getApplicationDocumentsDirectory();

  const appConfig = AppConfig(
    serverMediaUrl: 'http://192.168.1.74:8443/',
    serverChatWsUrl: 'ws://192.168.1.74:8443/chat',
  );

  final mediaCacheManager = MediaCacheManager(
    path: '${appDocs.path}/media',
  );
  await mediaCacheManager.init();

  return bootstrap(
    () {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: appConfig),
          RepositoryProvider.value(value: mediaCacheManager),
          RepositoryProvider.value(
            value: ChatClientRepository(
              serverMediaUrl: appConfig.serverMediaUrl,
              serverChatWsUrl: appConfig.serverChatWsUrl,
              dbPath: '${appDocs.path}/sputnikn.db',
              httpProxy: '',
            ),
          ),
        ],
        child: MainApp(),
      );
    },
  );
}
