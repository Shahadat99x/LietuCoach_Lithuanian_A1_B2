import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('traveler role pack audio references are bundled', () async {
    final jsonString = await rootBundle.loadString(
      'assets/packs/roles/traveler_v1.json',
    );
    final Map<String, dynamic> data =
        jsonDecode(jsonString) as Map<String, dynamic>;

    final audioPaths = <String>{};
    final scenarios = data['scenarios'] as List<dynamic>? ?? <dynamic>[];

    for (final scenario in scenarios) {
      final scenarioMap = scenario as Map<String, dynamic>;
      final dialogues =
          scenarioMap['dialogues'] as List<dynamic>? ?? <dynamic>[];
      for (final dialogue in dialogues) {
        final dialogueMap = dialogue as Map<String, dynamic>;
        final turns = dialogueMap['turns'] as List<dynamic>? ?? <dynamic>[];
        for (final turn in turns) {
          final turnMap = turn as Map<String, dynamic>;
          final path = turnMap['audioNormalPath'] as String?;
          if (path != null && path.isNotEmpty) {
            audioPaths.add(path);
          }
        }

        final takeaways =
            dialogueMap['takeaways'] as List<dynamic>? ?? <dynamic>[];
        for (final takeaway in takeaways) {
          final takeawayMap = takeaway as Map<String, dynamic>;
          final path = takeawayMap['audioNormalPath'] as String?;
          if (path != null && path.isNotEmpty) {
            audioPaths.add(path);
          }
        }
      }
    }

    expect(audioPaths, isNotEmpty);

    for (final path in audioPaths) {
      await rootBundle.load(path);
    }
  });
}
