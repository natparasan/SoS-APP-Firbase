import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:sos_alert_package/sos_alert_package.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';

class UserHomeScreen extends StatefulWidget {
  final Account account;
  const UserHomeScreen({super.key, required this.account});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _storage = ContactStorage();
  final _dispatcher = SosDispatcher();
  final _alertLog = AlertLog();

  List<EmergencyContact> _contacts = [];
  int _alertsSentCount = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await _storage.loadContacts();
    final events = await _alertLog.loadEvents();
    setState(() {
      _contacts = contacts;
      _alertsSentCount = events.where((e) => e.triggeredBy == widget.account.email).length;
    });
  }

  Future<void> _triggerSos() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an emergency contact first, from the Contacts tab.')),
      );
      return;
    }

    setState(() => _sending = true);
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    final results = await _dispatcher.sendToAll(_contacts);
    final failed = results.where((r) => !r.success).length;

    await _alertLog.logEvent(
      AlertEvent(
        triggeredBy: widget.account.email,
        timestamp: DateTime.now(),
        status: failed == 0 ? 'sent' : 'failed',
      ),
    );

    if (!mounted) return;
    setState(() => _sending = false);
    await _load();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed == 0
              ? 'SOS alert sent to all ${_contacts.length} contacts.'
              : '$failed of ${_contacts.length} alerts failed to open.',
        ),
      ),
    );
  }

  Future<void> _callEmergencyServices() async {
    await _dispatcher.callNumber('112');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        child: SingleChildScrollView(
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
                        'Hi, ${widget.account.name.split(' ').first} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stay safe today.',
                        style: TextStyle(color: Colors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _sending ? null : _triggerSos,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.sosGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emergencyRed.withOpacity(0.55),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _sending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
                                SizedBox(height: 6),
                                Text(
                                  'SOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tap to alert all contacts with your live location',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _callEmergencyServices,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text('Call Emergency Services'),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Emergency contacts',
                      value: '${_contacts.length}',
                      icon: Icons.contacts,
                      gradient: AppColors.sunsetGradient,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StatCard(
                      label: 'Alerts you\'ve sent',
                      value: '$_alertsSentCount',
                      icon: Icons.bolt,
                      gradient: AppColors.monitorGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
