import 'package:sputnikn_chat_client/websocket_chat_client.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sputnikn_chatsample/util/media_cache_manager.dart';
import '../services/chat_service/chat_service.dart';
import '../services/chat_service/chat_service_base.dart';
import '../services/data_hub_service/data_hub_service.dart';
import '../services/data_hub_service/data_hub_service_base.dart';
import 'app_config.dart';

class DI {
  DI._();

  static final injector = Injector();

  static Future<void> setup(AppConfig appConfig) async {
    WidgetsFlutterBinding.ensureInitialized();
    injector.map<AppConfig>((i) => appConfig);
    await _registerServices();
  }

  static Future<void> _registerServices() async {
    final appDocs = await getApplicationDocumentsDirectory();
    final chatClient = WebsocketChatClient(
      injector.get<AppConfig>().serverChatWsUrl,
      injector.get<AppConfig>().serverMediaUrl,
      "${appDocs.path}/sputnikn.db",
      "",
    );
    final mediaCacheManager = await MediaCacheManager.create(
      path: "${appDocs.path}/media",
    );
    injector.map<MediaCacheManager>(
      (i) => mediaCacheManager,
      isSingleton: true,
    );
    injector.map<DataHubServiceBase>(
      (i) => DataHubService(),
      isSingleton: true,
    );
    injector.map<ChatServiceBase>(
      (i) => ChatService(
        appConfig: i.get<AppConfig>(),
        chatClient: chatClient,
      ),
      isSingleton: true,
    );
  }
}
