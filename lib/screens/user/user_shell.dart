import 'package:flutter/material.dart';
import 'package:sos_alert_package/sos_alert_package.dart';
import '../../navigation/shell_back_handler.dart';
import '../../theme/app_theme.dart';
import 'user_home_screen.dart';
import 'user_contacts_screen.dart';
import 'user_history_screen.dart';
import 'user_profile_screen.dart';

/// Bottom-nav shell for a logged-in User: Home (SOS), Contacts,
/// History, and Profile.
class UserShell extends StatefulWidget {
  final Account account;
  const UserShell({super.key, required this.account});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      UserHomeScreen(account: widget.account),
      const UserContactsScreen(),
      const UserHistoryScreen(),
      UserProfileScreen(account: widget.account),
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
        indicatorColor: AppColors.violet.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.contacts_outlined), selectedIcon: Icon(Icons.contacts), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    ),
    );
  }
}
