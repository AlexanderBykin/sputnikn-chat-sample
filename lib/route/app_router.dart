import 'package:auto_route/auto_route.dart';
import 'package:sputnikn_chatsample/screens/chat_create/chat_create_screen.dart';
import 'package:sputnikn_chatsample/screens/chat_list/chat_list_screen.dart';
import 'package:sputnikn_chatsample/screens/chat_login/chat_login_screen.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/chat_thread_screen.dart';

@MaterialAutoRouter(
  //replaceInRouteName: 'Page|Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(
      path: '/',
      page: ChatLoginScreen,
      initial: true,
    ),
    CustomRoute(
      path: '/chat',
      name: 'ChatRouter',
      page: EmptyRouterPage,
      transitionsBuilder: TransitionsBuilders.slideLeft,
      durationInMilliseconds: 750,
      children: [
        AutoRoute(
          path: '',
          page: ChatListScreen,
        ),
        CustomRoute(
          path: 'create',
          page: ChatCreateScreen,
          transitionsBuilder: TransitionsBuilders.slideLeft,
          durationInMilliseconds: 750,
        ),
        CustomRoute(
          path: 'thread/:chatId',
          page: ChatThreadScreen,
          transitionsBuilder: TransitionsBuilders.slideLeft,
          durationInMilliseconds: 750,
        ),
      ],
    ),
  ],
)
class $AppRouter {}
