import 'package:shared_preferences/shared_preferences.dart';

class RoleProgressService {
  static const String _completedDialoguesKey = 'role_completed_dialogues';
  static const String _showTranslationKey = 'role_show_translation';

  Future<List<String>> getCompletedDialogueIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedDialoguesKey) ?? [];
  }

  Future<void> markDialogueComplete(String dialogueId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedDialoguesKey) ?? [];
    if (!completed.contains(dialogueId)) {
      completed.add(dialogueId);
      await prefs.setStringList(_completedDialoguesKey, completed);
    }
  }

  Future<bool> isDialogueComplete(String dialogueId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedDialoguesKey) ?? [];
    return completed.contains(dialogueId);
  }

  Future<int> getCompletedCount(List<String> dialogueIds) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedDialoguesKey) ?? [];
    int count = 0;
    for (var id in dialogueIds) {
      if (completed.contains(id)) {
        count++;
      }
    }
    return count;
  }

  Future<bool> getTranslationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true as per Phase 3 requirement
    return prefs.getBool(_showTranslationKey) ?? true;
  }

  Future<void> setTranslationPreference(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTranslationKey, show);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedDialoguesKey);
    await prefs.remove(_showTranslationKey);
  }
}

final roleProgressService = RoleProgressService();
