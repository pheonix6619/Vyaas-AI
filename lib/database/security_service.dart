import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Service handling secure storage of the database encryption key.
class SecurityService {
  static const _keyName = 'db_encryption_key';
  static final SecurityService _instance = SecurityService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SecurityService._internal();

  static SecurityService get instance => _instance;

  /// Retrieves the 256‑bit encryption key. Generates and stores it on first call.
  Future<Uint8List> getEncryptionKey() async {
    final stored = await _secureStorage.read(key: _keyName);
    if (stored != null) {
      return base64Decode(stored);
    }
    // Generate a secure random 256‑bit (32‑byte) key.
    final Uint8List key = Uint8List.fromList(Hive.generateSecureKey());
    final encoded = base64Encode(key);
    await _secureStorage.write(key: _keyName, value: encoded);
    return key;
  }
}
