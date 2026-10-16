import 'package:flutter/material.dart';
import 'package:sos_alert_package/sos_alert_package.dart';
import '../../theme/app_theme.dart';

class MonitorAlertsScreen extends StatefulWidget {
  const MonitorAlertsScreen({super.key});

  @override
  State<MonitorAlertsScreen> createState() => _MonitorAlertsScreenState();
}

class _MonitorAlertsScreenState extends State<MonitorAlertsScreen> {
  final _alertLog = AlertLog();
  List<AlertEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await _alertLog.loadEvents();
    setState(() => _events = events);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'sent':
        return AppColors.success;
      case 'failed':
        return AppColors.emergencyRed;
      default:
        return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Alerts'),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _events.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No alerts have been logged on this device yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final e = _events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(e.status).withOpacity(0.15),
                        child: Icon(Icons.bolt, color: _statusColor(e.status)),
                      ),
                      title: Text(e.triggeredBy),
                      subtitle: Text(
                        '${e.timestamp.day}/${e.timestamp.month}/${e.timestamp.year} '
                        '${e.timestamp.hour.toString().padLeft(2, '0')}:'
                        '${e.timestamp.minute.toString().padLeft(2, '0')} · ${e.status}',
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
