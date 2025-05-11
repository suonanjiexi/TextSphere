import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'app_logger.dart';

/// 安全存储工具类
///
/// 提供加密存储敏感数据的功能，适用于不同安全级别的数据
class SecureStorage {
  // 单例实现
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  // 安全存储实例
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

  // SharedPreferences实例，用于非敏感数据
  SharedPreferences? _sharedPreferences;

  // 加密密钥 (静态密钥仅用于非极敏感数据)
  encrypt.Key? _encryptionKey;
  encrypt.IV? _encryptionIV;

  // 是否已初始化
  bool _isInitialized = false;

  /// 初始化安全存储
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 获取SharedPreferences实例
      _sharedPreferences = await SharedPreferences.getInstance();

      // 初始化加密器
      await _initializeEncryptor();

      _isInitialized = true;
      logger.i('安全存储初始化完成');
    } catch (e) {
      logger.e('安全存储初始化失败: $e');
      rethrow;
    }
  }

  /// 初始化加密器
  Future<void> _initializeEncryptor() async {
    try {
      // 从安全存储中获取密钥，如果不存在则创建新密钥
      String? storedKey = await _secureStorage.read(key: 'encryption_key');
      String? storedIV = await _secureStorage.read(key: 'encryption_iv');

      if (storedKey == null || storedIV == null) {
        // 生成新的密钥和IV
        final keyBytes = encrypt.Key.fromSecureRandom(32);
        final ivBytes = encrypt.IV.fromSecureRandom(16);

        // 存储密钥和IV
        await _secureStorage.write(
          key: 'encryption_key',
          value: base64Encode(keyBytes.bytes),
        );
        await _secureStorage.write(
          key: 'encryption_iv',
          value: base64Encode(ivBytes.bytes),
        );

        _encryptionKey = keyBytes;
        _encryptionIV = ivBytes;
      } else {
        // 使用存储的密钥和IV
        _encryptionKey = encrypt.Key(base64Decode(storedKey));
        _encryptionIV = encrypt.IV(base64Decode(storedIV));
      }
    } catch (e) {
      logger.e('初始化加密器失败: $e');
      // 使用备用固定密钥，仅用于开发环境
      if (kDebugMode) {
        final fallbackKey =
            sha256.convert(utf8.encode('flutter_dev_key')).bytes;
        _encryptionKey = encrypt.Key(Uint8List.fromList(fallbackKey));
        _encryptionIV = encrypt.IV.fromLength(16);
        logger.w('使用备用开发密钥');
      } else {
        rethrow;
      }
    }
  }

  /// 安全存储字符串 (最高安全级别)
  Future<void> secureWrite(String key, String value) async {
    await _assertInitialized();
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      logger.e('安全写入失败: $e');
      rethrow;
    }
  }

  /// 读取安全存储的字符串
  Future<String?> secureRead(String key) async {
    await _assertInitialized();
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      logger.e('安全读取失败: $e');
      return null;
    }
  }

  /// 删除安全存储的数据
  Future<void> secureDelete(String key) async {
    await _assertInitialized();
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      logger.e('安全删除失败: $e');
    }
  }

  /// 存储加密数据 (中等安全级别，适用于较大数据)
  Future<bool> encryptedWrite(String key, String value) async {
    await _assertInitialized();
    try {
      if (_encryptionKey == null || _encryptionIV == null) {
        throw Exception('加密密钥未初始化');
      }

      // 使用AES加密数据
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.cbc),
      );
      final encrypted = encrypter.encrypt(value, iv: _encryptionIV!);

      // 存储加密数据
      return await _sharedPreferences!.setString(key, encrypted.base64);
    } catch (e) {
      logger.e('加密写入失败: $e');
      return false;
    }
  }

  /// 读取加密数据
  Future<String?> encryptedRead(String key) async {
    await _assertInitialized();
    try {
      if (_encryptionKey == null || _encryptionIV == null) {
        throw Exception('加密密钥未初始化');
      }

      // 获取加密数据
      final encryptedData = _sharedPreferences!.getString(key);
      if (encryptedData == null) {
        return null;
      }

      // 解密数据
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(encryptedData),
        iv: _encryptionIV!,
      );

      return decrypted;
    } catch (e) {
      logger.e('加密读取失败: $e');
      return null;
    }
  }

  /// 删除加密数据
  Future<bool> encryptedDelete(String key) async {
    await _assertInitialized();
    try {
      return await _sharedPreferences!.remove(key);
    } catch (e) {
      logger.e('加密删除失败: $e');
      return false;
    }
  }

  /// 存储普通数据 (低安全级别，适用于非敏感数据)
  Future<bool> write(String key, String value) async {
    await _assertInitialized();
    try {
      return await _sharedPreferences!.setString(key, value);
    } catch (e) {
      logger.e('普通写入失败: $e');
      return false;
    }
  }

  /// 读取普通数据
  Future<String?> read(String key) async {
    await _assertInitialized();
    try {
      return _sharedPreferences!.getString(key);
    } catch (e) {
      logger.e('普通读取失败: $e');
      return null;
    }
  }

  /// 删除普通数据
  Future<bool> delete(String key) async {
    await _assertInitialized();
    try {
      return await _sharedPreferences!.remove(key);
    } catch (e) {
      logger.e('普通删除失败: $e');
      return false;
    }
  }

  /// 清除所有安全存储的数据
  Future<void> clearAll() async {
    await _assertInitialized();
    try {
      await _secureStorage.deleteAll();
      await _sharedPreferences!.clear();
      logger.i('已清除所有存储数据');
    } catch (e) {
      logger.e('清除所有数据失败: $e');
    }
  }

  /// 确保已初始化
  Future<void> _assertInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// 生成数据哈希
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 验证数据哈希
  bool verifyHash(String data, String hash) {
    final calculatedHash = generateHash(data);
    return calculatedHash == hash;
  }

  /// 获取用户会话令牌
  Future<String?> getAuthToken() async {
    return await secureRead('auth_token');
  }

  /// 保存用户会话令牌
  Future<void> saveAuthToken(String token) async {
    await secureWrite('auth_token', token);
  }

  /// 清除用户会话令牌
  Future<void> clearAuthToken() async {
    await secureDelete('auth_token');
  }
}
