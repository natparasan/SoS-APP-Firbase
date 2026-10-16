import 'package:flutter/material.dart';
import 'package:sos_alert_package/sos_alert_package.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';

class MonitorDashboardScreen extends StatefulWidget {
  final Account account;
  const MonitorDashboardScreen({super.key, required this.account});

  @override
  State<MonitorDashboardScreen> createState() => _MonitorDashboardScreenState();
}

class _MonitorDashboardScreenState extends State<MonitorDashboardScreen> {
  final _watchedStore = WatchedUsersStore();
  final _alertLog = AlertLog();

  List<WatchedUser> _watched = [];
  List<AlertEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final watched = await _watchedStore.loadFor(widget.account.email);
    final events = await _alertLog.loadEvents();
    setState(() {
      _watched = watched;
      _events = events;
    });
  }

  Future<void> _addWatchedUser() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<WatchedUser>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Link a person to watch'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Their name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Their account email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  WatchedUser(name: nameController.text.trim(), email: emailController.text.trim()),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _watchedStore.addFor(widget.account.email, result);
      await _load();
    }
  }

  int _alertsFor(String email) => _events.where((e) => e.triggeredBy == email).length;

  bool _hasRecentAlert(String email) {
    final matches = _events.where((e) => e.triggeredBy == email);
    if (matches.isEmpty) return false;
    return DateTime.now().difference(matches.first.timestamp) < const Duration(hours: 12);
  }

  @override
  Widget build(BuildContext context) {
    final totalAlerts = _events.length;
    final activeAlerts = _watched.where((w) => _hasRecentAlert(w.email)).length;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.monitorGradient),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${widget.account.name.split(' ').first} 🛡️',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Monitoring ${_watched.length} people',
                          style: TextStyle(color: Colors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.shield_moon, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Active alerts (12h)',
                        value: '$activeAlerts',
                        icon: Icons.warning_amber_rounded,
                        gradient: AppColors.sosGradient,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: StatCard(
                        label: 'Total alerts logged',
                        value: '$totalAlerts',
                        icon: Icons.bar_chart,
                        gradient: AppColors.sunsetGradient,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'People you watch',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _addWatchedUser,
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(Icons.add),
                      label: const Text('Link person'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_watched.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'No one linked yet. Tap "Link person" and enter the '
                      'email they used to register as a User.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  ..._watched.map((w) {
                    final alertActive = _hasRecentAlert(w.email);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                alertActive ? AppColors.emergencyRed : AppColors.teal,
                            child: Text(
                              w.name.isNotEmpty ? w.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(
                                  w.email,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (alertActive ? AppColors.emergencyRed : AppColors.success)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              alertActive ? 'ALERT' : 'SAFE',
                              style: TextStyle(
                                color: alertActive ? AppColors.emergencyRed : AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
