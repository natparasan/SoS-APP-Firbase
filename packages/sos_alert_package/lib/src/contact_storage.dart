import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'emergency_contact.dart';

class ContactStorage {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _contacts {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('contacts');
  }

  Future<List<EmergencyContact>> loadContacts() async {
    final snapshot = await _contacts.get();
    return snapshot.docs
        .map((d) => EmergencyContact.fromJson(d.data()))
        .toList();
  }

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final existing = await _contacts.get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }
    for (final contact in contacts) {
      await _contacts.add(contact.toJson());
    }
  }

  Future<void> addContact(EmergencyContact contact) async {
    await _contacts.add(contact.toJson());
  }

  Future<void> removeContact(String phoneNumber) async {
    final snapshot =
        await _contacts.where('phoneNumber', isEqualTo: phoneNumber).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
