import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/db_helper.dart';
import '../models/app_user.dart';

class AuthResult {
  final bool ok;
  final String message;
  const AuthResult(this.ok, this.message);
}

/// Register, login, dan sesi pengguna (disimpan di SQLite + SharedPreferences).
/// Password TIDAK disimpan polos: disimpan sebagai SHA-256(salt:password) + salt acak.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _sessionKey = 'session_user_id';

  AppUser? currentUser;

  String _newSalt() {
    final rnd = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  /// Dipanggil saat aplikasi dibuka: mengembalikan user bila sesi masih ada.
  Future<AppUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_sessionKey);
    if (id == null) return null;
    currentUser = await DbHelper.instance.getUserById(id);
    if (currentUser == null) await prefs.remove(_sessionKey);
    return currentUser;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final mail = email.trim().toLowerCase();
    if (await DbHelper.instance.getUserByEmail(mail) != null) {
      return const AuthResult(false, 'Email sudah terdaftar. Gunakan email lain atau masuk.');
    }
    final salt = _newSalt();
    await DbHelper.instance.insertUser(AppUser(
      name: name.trim(),
      email: mail,
      passwordHash: _hash(password, salt),
      salt: salt,
    ));
    return const AuthResult(true, 'Registrasi berhasil');
  }

  Future<AuthResult> login({required String email, required String password}) async {
    final user = await DbHelper.instance.getUserByEmail(email.trim().toLowerCase());
    if (user == null || user.passwordHash != _hash(password, user.salt)) {
      return const AuthResult(false, 'Email atau password salah.');
    }
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, user.id!);
    return const AuthResult(true, 'Login berhasil');
  }

  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> refreshUser() async {
    final id = currentUser?.id;
    if (id != null) currentUser = await DbHelper.instance.getUserById(id);
  }
}
