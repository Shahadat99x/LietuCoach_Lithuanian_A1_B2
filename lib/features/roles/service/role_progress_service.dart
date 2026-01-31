import 'package:shared_preferences/shared_preferences.dart';

class RoleProgressService {
  static const String _completedDialoguesKey = 'role_completed_dialogues';

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
}

final roleProgressService = RoleProgressService();
