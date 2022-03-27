import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sputnikn_chatsample/core/themes/default_theme.dart';
import 'package:sputnikn_chatsample/route/app_router.gr.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  MainApp({
    Key? key,
  }) : super(key: key);

  final _appRouter = AppRouter(_navigatorKey);

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
