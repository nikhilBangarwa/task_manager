import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favKey = 'favorite_post_ids';

  Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_favKey);
    if (saved == null) return {};
    return saved.map((e) => int.parse(e)).toSet();
  }

  Future<void> saveFavorites(Set<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> toSave = favoriteIds.map((e) => e.toString()).toList();
    await prefs.setStringList(_favKey, toSave);
  }
}
