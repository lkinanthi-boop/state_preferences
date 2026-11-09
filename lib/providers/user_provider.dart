import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  User get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  int _visitCount = 0;
  int get visitCount => _visitCount;

  List<String> _favorites = [];
  List<String> get favorites => List.unmodifiable(_favorites);

  // Memuat data saat provider dibuat
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isDark = prefs.getBool('is_dark_mode') ?? false;

    final oldVisitCount = prefs.getInt('visit_count') ?? 0;
    final newVisitCount = oldVisitCount + 1;
    await prefs.setInt('visit_count', newVisitCount);

    final favorites = prefs.getStringList('favorites') ?? [];

    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isDarkMode = isDark;
    _visitCount = newVisitCount;
    _favorites = favorites;
    _isLoading = false;

    notifyListeners();
  }

  // Menyimpan data user
  Future<void> updateUser(User newUser) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(isLoggedIn: false);

    notifyListeners();
  }

  // Mengubah tema
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = !_isDarkMode;

    await prefs.setBool('is_dark_mode', value);
    _isDarkMode = value;
    notifyListeners();
  }

  // Menambahkan favorit
  Future<void> addFavorite(String item) async {
    final newItem = item.trim();

    if (newItem.isEmpty || _favorites.contains(newItem)) {
      return;
    }

    final updatedFavorites = [..._favorites, newItem];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', updatedFavorites);

    _favorites = updatedFavorites;
    notifyListeners();
  }

  // Menghapus favorit
  Future<void> removeFavorite(String item) async {
    final updatedFavorites = _favorites
        .where((favorite) => favorite != item)
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', updatedFavorites);

    _favorites = updatedFavorites;
    notifyListeners();
  }
}
