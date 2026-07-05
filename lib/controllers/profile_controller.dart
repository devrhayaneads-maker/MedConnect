import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';

/// Nome e e-mail exibidos no Perfil. Editáveis e persistidos no
/// próprio aparelho (não há backend de perfil real ainda).
class ProfileController extends ChangeNotifier {
  ProfileController() {
    _load();
  }

  static const String _nameKey = 'profile_name';
  static const String _emailKey = 'profile_email';

  String _name = MockData.userName;
  String get name => _name;

  String _email = MockData.userEmail;
  String get email => _email;

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedName = prefs.getString(_nameKey);
    final String? savedEmail = prefs.getString(_emailKey);
    if ((savedName != null && savedName.trim().isNotEmpty) ||
        (savedEmail != null && savedEmail.trim().isNotEmpty)) {
      if (savedName != null && savedName.trim().isNotEmpty) _name = savedName;
      if (savedEmail != null && savedEmail.trim().isNotEmpty) {
        _email = savedEmail;
      }
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    final String trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == _name) return;
    _name = trimmed;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, trimmed);
  }

  Future<void> updateEmail(String newEmail) async {
    final String trimmed = newEmail.trim();
    if (trimmed.isEmpty || trimmed == _email) return;
    _email = trimmed;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, trimmed);
  }
}
