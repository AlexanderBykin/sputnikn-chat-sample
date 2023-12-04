import 'package:auto_route/auto_route.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sputnikn_chatsample/app_router/app_router.dart';
import 'package:sputnikn_chatsample/app_router/authentication_guard.dart';
import 'package:sputnikn_chatsample/core/themes/default_theme.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    _appRouter = AppRouter(
      navigatorKey: _navigatorKey,
      authGuard: AuthenticationGuard(
        isAuthenticated: () =>
            context.read<ChatClientRepository>().isAuthenticated,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: Themes.appTheme,
      routerDelegate: AutoRouterDelegate(_appRouter),
      routeInformationParser: _appRouter.defaultRouteParser(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)?.app_title ?? '',
    );
  }
}
