import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/jwt_utils.dart';

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});

// Exposes the current session user id (if any) as a FutureProvider
final sessionUserIdProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(authStorageProvider);
  return await storage.getUserId();
});

class AuthStorage {
  final _storage = const FlutterSecureStorage();
  final _tokenKey = 'jwt_token';
  final _userIdKey = 'user_id';
  final _emailKey = 'user_email';
  final _roleKey = 'user_role';
  final _landingSeenKey = 'landing_seen';
  final _faskesProfileIdKey = 'faskes_profile_id';

  // Simpan token saat berhasil login
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Ambil token untuk disuntikkan ke Header API
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveFaskesProfileId(String id) async {
    await _storage.write(key: _faskesProfileIdKey, value: id);
  }

  Future<String?> getFaskesProfileId() async {
    return await _storage.read(key: _faskesProfileIdKey);
  }

  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    return JwtUtils.isUsable(token);
  }

  // Simpan role jika dibutuhkan untuk penentuan halaman awal
  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  // Simpan User ID setelah login atau dekode token
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Ambil User ID untuk keperluan query data lokal/spesifik user
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Simpan Email pengguna
  Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  // Ambil Email untuk ditampilkan di profil (Fitur Data Pribadi)
  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<bool> hasSeenLanding() async {
    return (await _storage.read(key: _landingSeenKey)) == 'true';
  }

  Future<void> markLandingSeen() async {
    await _storage.write(key: _landingSeenKey, value: 'true');
  }

  // Hapus semua session saat logout atau token expired
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _faskesProfileIdKey);
  }
}
