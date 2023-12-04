import 'package:auto_route/auto_route.dart';
import 'package:sputnikn_chatsample/app_router/app_router.dart';

class AuthenticationGuard implements AutoRouteGuard {
  AuthenticationGuard({
    required this.isAuthenticated,
  });

  final bool Function() isAuthenticated;

  @override
  void onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) {
    final _isAuthenticated = isAuthenticated();

    if (resolver.route.name == HomeRoute.name) {
      if (_isAuthenticated) {
        resolver.next();
        return;
      } else {
        resolver.next(false);
        router.replace(const ChatLoginRoute());
        return;
      }
    } else if (resolver.route.name == ChatLoginRoute.name) {
      if (_isAuthenticated) {
        resolver.next(false);
        return;
      } else {
        resolver.next();
        return;
      }
    }

    resolver.next();
  }
}
