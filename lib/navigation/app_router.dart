import 'package:flutter/material.dart';
import 'package:sos_alert_package/sos_alert_package.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/user/user_shell.dart';
import '../screens/monitor/monitor_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const userHome = '/user';
  static const monitorHome = '/monitor';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    final arg = s.arguments;
    final Widget page = switch (s.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.register => RegisterScreen(initialRole: arg is UserRole ? arg : UserRole.user),
      AppRoutes.userHome when arg is Account => UserShell(account: arg),
      AppRoutes.monitorHome when arg is Account => MonitorShell(account: arg),
      _ => const LoginScreen(),
    };
    return PageRouteBuilder(
      settings: s,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    );
  }
}

extension AppNavigation on BuildContext {
  void goToLogin() => Navigator.pushNamedAndRemoveUntil(this, AppRoutes.login, (_) => false);

  void goToRegister(UserRole role) => Navigator.pushNamed(this, AppRoutes.register, arguments: role);

  void goToHome(Account? account) {
    if (account == null) return goToLogin();
    final route = account.role == UserRole.user ? AppRoutes.userHome : AppRoutes.monitorHome;
    Navigator.pushNamedAndRemoveUntil(this, route, (_) => false, arguments: account);
  }
}
