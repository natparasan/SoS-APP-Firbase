import 'package:flutter/material.dart';
import 'package:sos_alert_package/sos_alert_package.dart';
import '../../navigation/shell_back_handler.dart';
import '../../theme/app_theme.dart';
import 'monitor_dashboard_screen.dart';
import 'monitor_alerts_screen.dart';
import 'monitor_profile_screen.dart';

/// Bottom-nav shell for a logged-in Monitor: Dashboard, Alerts, Profile.
class MonitorShell extends StatefulWidget {
  final Account account;
  const MonitorShell({super.key, required this.account});

  @override
  State<MonitorShell> createState() => _MonitorShellState();
}

class _MonitorShellState extends State<MonitorShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      MonitorDashboardScreen(account: widget.account),
      const MonitorAlertsScreen(),
      MonitorProfileScreen(account: widget.account),
    ];

    return ShellBackHandler(
      currentIndex: _index,
      onGoToFirstTab: () => setState(() => _index = 0),
      child: Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i != _index) setState(() => _index = i);
        },
        indicatorColor: AppColors.teal.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    ),
    );
  }
}
