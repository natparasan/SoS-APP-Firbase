import 'package:cloud_firestore/cloud_firestore.dart';

class WatchedUser {
  final String name;
  final String email;

  const WatchedUser({required this.name, required this.email});

  Map<String, dynamic> toJson() => {'name': name, 'email': email};

  factory WatchedUser.fromJson(Map<String, dynamic> json) =>
      WatchedUser(name: json['name'] as String, email: json['email'] as String);
}

/// Stores, per Monitor (keyed by the monitor's own email), the list of
/// Users they watch — in a shared Firestore collection so it's visible
/// from any device the Monitor signs into.
class WatchedUsersStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _entriesFor(String monitorEmail) {
    return _db.collection('watchlists').doc(monitorEmail).collection('entries');
  }

  Future<List<WatchedUser>> loadFor(String monitorEmail) async {
    final snapshot = await _entriesFor(monitorEmail).get();
    return snapshot.docs.map((d) => WatchedUser.fromJson(d.data())).toList();
  }

  Future<void> saveFor(String monitorEmail, List<WatchedUser> users) async {
    final existing = await _entriesFor(monitorEmail).get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }
    for (final user in users) {
      await _entriesFor(monitorEmail).add(user.toJson());
    }
  }

  Future<void> addFor(String monitorEmail, WatchedUser user) async {
    await _entriesFor(monitorEmail).add(user.toJson());
  }

  Future<void> removeFor(String monitorEmail, String userEmail) async {
    final snapshot = await _entriesFor(monitorEmail)
        .where('email', isEqualTo: userEmail)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
