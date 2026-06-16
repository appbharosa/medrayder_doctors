import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_model.dart';


class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    await _storage.write(key: 'access_token', value: user.accessToken);
    await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
  }

  Future<void> loadUser() async {
    final userDataJson = await _storage.read(key: 'user_data');
    if (userDataJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userDataJson);
      _currentUser = UserModel.fromJson(userMap);
    }
  }

  Future<void> clearUser() async {
    _currentUser = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_data');
  }

  String? get accessToken => _currentUser?.accessToken;
}