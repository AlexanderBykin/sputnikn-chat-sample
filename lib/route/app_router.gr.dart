// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i2;
import 'package:flutter/material.dart' as _i6;
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart' as _i7;

import '../screens/chat_create/view/chat_create_screen.dart' as _i4;
import '../screens/chat_list/view/chat_list_screen.dart' as _i3;
import '../screens/chat_login/view/chat_login_screen.dart' as _i1;
import '../screens/chat_thread/view/chat_thread_screen.dart' as _i5;

class AppRouter extends _i2.RootStackRouter {
  AppRouter([_i6.GlobalKey<_i6.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i2.PageFactory> pagesMap = {
    ChatLoginScreenRoute.name: (routeData) {
      return _i2.CustomPage<void>(
          routeData: routeData,
          child: const _i1.ChatLoginScreen(),
          customRouteBuilder: _i1.ChatLoginScreen.route,
          opaque: true,
          barrierDismissible: false);
    },
    ChatRouter.name: (routeData) {
      return _i2.CustomPage<void>(
          routeData: routeData,
          child: const _i2.EmptyRouterPage(),
          transitionsBuilder: _i2.TransitionsBuilders.slideLeft,
          durationInMilliseconds: 650,
          opaque: true,
          barrierDismissible: false);
    },
    ChatListScreenRoute.name: (routeData) {
      return _i2.CustomPage<void>(
          routeData: routeData,
          child: const _i3.ChatListScreen(),
          customRouteBuilder: _i3.ChatListScreen.route,
          opaque: true,
          barrierDismissible: false);
    },
    ChatCreateScreenRoute.name: (routeData) {
      return _i2.CustomPage<_i7.RoomDetail>(
          routeData: routeData,
          child: const _i4.ChatCreateScreen(),
          customRouteBuilder: _i4.ChatCreateScreen.route,
          transitionsBuilder: _i2.TransitionsBuilders.slideLeft,
          durationInMilliseconds: 650,
          opaque: true,
          barrierDismissible: false);
    },
    ChatThreadScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ChatThreadScreenRouteArgs>(
          orElse: () => ChatThreadScreenRouteArgs(
              chatId: pathParams.getString('chatId')));
      return _i2.CustomPage<void>(
          routeData: routeData,
          child: _i5.ChatThreadScreen(chatId: args.chatId, key: args.key),
          customRouteBuilder: _i5.ChatThreadScreen.route,
          transitionsBuilder: _i2.TransitionsBuilders.slideLeft,
          durationInMilliseconds: 650,
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i2.RouteConfig> get routes => [
        _i2.RouteConfig(ChatLoginScreenRoute.name, path: '/'),
        _i2.RouteConfig(ChatRouter.name, path: '/chat', children: [
          _i2.RouteConfig(ChatListScreenRoute.name,
              path: '', parent: ChatRouter.name),
          _i2.RouteConfig(ChatCreateScreenRoute.name,
              path: 'create', parent: ChatRouter.name),
          _i2.RouteConfig(ChatThreadScreenRoute.name,
              path: 'thread/:chatId', parent: ChatRouter.name)
        ])
      ];
}

/// generated route for
/// [_i1.ChatLoginScreen]
class ChatLoginScreenRoute extends _i2.PageRouteInfo<void> {
  const ChatLoginScreenRoute() : super(ChatLoginScreenRoute.name, path: '/');

  static const String name = 'ChatLoginScreenRoute';
}

/// generated route for
/// [_i2.EmptyRouterPage]
class ChatRouter extends _i2.PageRouteInfo<void> {
  const ChatRouter({List<_i2.PageRouteInfo>? children})
      : super(ChatRouter.name, path: '/chat', initialChildren: children);

  static const String name = 'ChatRouter';
}

/// generated route for
/// [_i3.ChatListScreen]
class ChatListScreenRoute extends _i2.PageRouteInfo<void> {
  const ChatListScreenRoute() : super(ChatListScreenRoute.name, path: '');

  static const String name = 'ChatListScreenRoute';
}

/// generated route for
/// [_i4.ChatCreateScreen]
class ChatCreateScreenRoute extends _i2.PageRouteInfo<void> {
  const ChatCreateScreenRoute()
      : super(ChatCreateScreenRoute.name, path: 'create');

  static const String name = 'ChatCreateScreenRoute';
}

/// generated route for
/// [_i5.ChatThreadScreen]
class ChatThreadScreenRoute
    extends _i2.PageRouteInfo<ChatThreadScreenRouteArgs> {
  ChatThreadScreenRoute({required String chatId, _i6.Key? key})
      : super(ChatThreadScreenRoute.name,
            path: 'thread/:chatId',
            args: ChatThreadScreenRouteArgs(chatId: chatId, key: key),
            rawPathParams: {'chatId': chatId});

  static const String name = 'ChatThreadScreenRoute';
}

class ChatThreadScreenRouteArgs {
  const ChatThreadScreenRouteArgs({required this.chatId, this.key});

  final String chatId;

  final _i6.Key? key;

  @override
  String toString() {
    return 'ChatThreadScreenRouteArgs{chatId: $chatId, key: $key}';
  }
}
