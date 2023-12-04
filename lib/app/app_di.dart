import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sputnikn_chatsample/core/core.dart';

abstract class AppDI {
  static Future<List<RepositoryProvider<dynamic>>> buildRepositoryProviders(
    AppConfig appConfig,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();

    final appDocs = await getApplicationDocumentsDirectory();

    final mediaCacheManager = MediaCacheManager(
      path: '${appDocs.path}/media',
    );
    await mediaCacheManager.init();

    return [
      RepositoryProvider<AppConfig>.value(
        value: appConfig,
      ),
      RepositoryProvider<MediaCacheManager>.value(
        value: mediaCacheManager,
      ),
      RepositoryProvider<ChatClientRepository>.value(
        value: ChatClientRepository(
          serverMediaUrl: appConfig.serverMediaUrl,
          serverChatWsUrl: appConfig.serverChatWsUrl,
          dbPath: '${appDocs.path}/sputnikn.db',
          httpProxy: '',
        ),
      ),
    ];
  }
}
