import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/app_router/authentication_guard.dart';
import 'package:sputnikn_chatsample/pages/pages.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(
  generateForDir: [
    'lib/app_router',
    'lib/pages',
  ],
)
class AppRouter extends _$AppRouter {
  AppRouter({
    required this.authGuard,
    super.navigatorKey,
  });

  final AuthenticationGuard authGuard;

  @override
  List<AutoRoute> get routes => [
        AdaptiveRoute(
          path: '/signin',
          page: ChatLoginRoute.page,
        ),
        AdaptiveRoute(
          path: '/',
          page: HomeRoute.page,
          guards: [authGuard],
          children: [
            AdaptiveRoute(
              initial: true,
              path: 'chats',
              page: ChatListRoute.page,
            ),
            AdaptiveRoute(
              path: 'create',
              page: ChatCreateRoute.page,
            ),
            AdaptiveRoute(
              path: 'chatThread/:chatId',
              page: ChatThreadRoute.page,
            ),
          ],
        ),
      ];
}
