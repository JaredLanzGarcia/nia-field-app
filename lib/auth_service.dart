import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // The Controller that broadcasts the session status
  final _authController = StreamController<bool>();

  // Expose the stream to the UI
  Stream<bool> get authStatus => _authController.stream;

  // Check initial state (call this when app starts)
  Future<void> checkStatus() async {
    String? token = await _storage.read(key: 'jwt_token');
    _authController.add(token != null);
  }

  Future<void> login(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
    _authController.add(true); // Notify StreamBuilder
  }

  // Inside your AuthService class
  Future<void> logout() async {
    // 1. Delete the token from secure storage
    await _storage.delete(key: 'jwt_token');

    // 2. Push 'false' to the stream so the UI reacts
    _authController.add(false);
  }
}
