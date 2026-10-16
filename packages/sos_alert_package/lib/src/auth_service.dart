import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account.dart';
import 'user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      await _users.doc(uid).set({
        'name': name,
        'email': email.trim(),
        'role': role.storageValue,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed.';
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final doc = await _users.doc(uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        return 'No profile found for this account.';
      }
      final data = doc.data()!;
      final storedRole = UserRoleX.fromString(data['role'] as String);
      if (storedRole != role) {
        await _auth.signOut();
        return 'This email is registered as a ${storedRole.label}, not a ${role.label}. '
            'Switch tabs above.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed.';
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<Account?> currentAccount() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return Account(
      uid: user.uid,
      name: data['name'] as String,
      email: data['email'] as String,
      role: UserRoleX.fromString(data['role'] as String),
    );
  }
}
