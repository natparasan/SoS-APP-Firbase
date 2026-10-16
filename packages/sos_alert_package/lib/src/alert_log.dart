import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertEvent {
  final String triggeredBy;
  final DateTime timestamp;
  final String? mapsLink;
  final String status;

  const AlertEvent({
    required this.triggeredBy,
    required this.timestamp,
    required this.status,
    this.mapsLink,
  });

  Map<String, dynamic> toJson() => {
        'triggeredBy': triggeredBy,
        'timestamp': Timestamp.fromDate(timestamp),
        'mapsLink': mapsLink,
        'status': status,
      };

  factory AlertEvent.fromJson(Map<String, dynamic> json) => AlertEvent(
        triggeredBy: json['triggeredBy'] as String,
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        mapsLink: json['mapsLink'] as String?,
        status: json['status'] as String,
      );
}

/// Alerts are written to a shared top-level Firestore collection (tagged
/// with the uid and email of whoever triggered them) so that a Monitor's
/// own device can see alerts raised on a different User's device.
class AlertLog {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alerts =>
      _db.collection('alerts');

  Future<List<AlertEvent>> loadEvents() async {
    final snapshot =
        await _alerts.orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((d) => AlertEvent.fromJson(d.data())).toList();
  }

  Future<void> logEvent(AlertEvent event) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await _alerts.add({
      ...event.toJson(),
      'ownerUid': uid,
    });
  }
}
