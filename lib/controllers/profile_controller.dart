import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';

/// Nome do usuário exibido no Perfil. Editável e persistido no
/// próprio aparelho (não há backend de perfil real ainda).
class ProfileController extends ChangeNotifier {
  ProfileController() {
    _load();
  }

  static const String _prefsKey = 'profile_name';

  String _name = MockData.userName;
  String get name => _name;

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_prefsKey);
    if (saved != null && saved.trim().isNotEmpty) {
      _name = saved;
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    final String trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == _name) return;
    _name = trimmed;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, trimmed);
  }
}
