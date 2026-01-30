import 'package:shared_preferences/shared_preferences.dart';

enum PathStyle { list, map }

class PathPreferencesService {
  static const String _keyPathStyle = 'path_style_preference';

  // Singleton instance
  static final PathPreferencesService _instance =
      PathPreferencesService._internal();
  factory PathPreferencesService() => _instance;
  PathPreferencesService._internal();

  Future<PathStyle> getPathStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyPathStyle);
    if (index == null || index < 0 || index >= PathStyle.values.length) {
      return PathStyle.list; // Default
    }
    return PathStyle.values[index];
  }

  Future<void> setPathStyle(PathStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPathStyle, style.index);
  }
}
