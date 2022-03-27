import 'package:auto_route/auto_route.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/screens/chat_create/view/chat_create_screen.dart';
import 'package:sputnikn_chatsample/screens/chat_list/view/chat_list_screen.dart';
import 'package:sputnikn_chatsample/screens/chat_login/view/chat_login_screen.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/view/chat_thread_screen.dart';

@MaterialAutoRouter(
  //replaceInRouteName: 'Page|Screen,Route',
  routes: <AutoRoute>[
    CustomRoute<void>(
      path: '/',
      page: ChatLoginScreen,
      customRouteBuilder: ChatLoginScreen.route,
      initial: true,
    ),
    CustomRoute<void>(
      path: '/chat',
      name: 'ChatRouter',
      page: EmptyRouterPage,
      transitionsBuilder: TransitionsBuilders.slideLeft,
      durationInMilliseconds: 650,
      children: [
        CustomRoute<void>(
          path: '',
          page: ChatListScreen,
          customRouteBuilder: ChatListScreen.route,
        ),
        CustomRoute<RoomDetail>(
          path: 'create',
          page: ChatCreateScreen,
          customRouteBuilder: ChatCreateScreen.route,
          transitionsBuilder: TransitionsBuilders.slideLeft,
          durationInMilliseconds: 650,
        ),
        CustomRoute<void>(
          path: 'thread/:chatId',
          page: ChatThreadScreen,
          customRouteBuilder: ChatThreadScreen.route,
          transitionsBuilder: TransitionsBuilders.slideLeft,
          durationInMilliseconds: 650,
        ),
      ],
    ),
  ],
)
class $AppRouter {}
