import 'dart:io';
import 'dart:convert';

void main() async {
  final jsonFile = File('assets/packs/roles/traveler_v1.json');
  if (!jsonFile.existsSync()) {
    print('JSON file not found');
    exit(1);
  }

  final content = await jsonFile.readAsString();
  final data = jsonDecode(content);

  final paths = <String>[];

  // Parse scenarios
  for (var scenario in data['scenarios']) {
    for (var dialogue in scenario['dialogues']) {
      // Turns
      for (var turn in dialogue['turns']) {
        if (turn['audioNormalPath'] != null) paths.add(turn['audioNormalPath']);
        if (turn['audioSlowPath'] != null) paths.add(turn['audioSlowPath']);
      }
      // Takeaways
      if (dialogue['takeaways'] != null) {
        for (var takeaway in dialogue['takeaways']) {
          if (takeaway['audioNormalPath'] != null)
            paths.add(takeaway['audioNormalPath']);
        }
      }
    }
  }

  print('Found ${paths.length} audio references.');

  int created = 0;
  for (var path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      print('Missing: $path - Creating placeholder...');
      file.createSync(recursive: true); // Create dirs if needed
      // Write dummy MP3 header or just empty?
      // Empty file might cause player error.
      // Minimal valid MP3 frame is better, but empty might suffice for "file exists" check.
      // Let's write a small text "PLACEHOLDER" - player will fail to decode but file exists.
      // Or better, let's copy a dummy file if we had one.
      // We'll write bytes.
      file.writeAsBytesSync([0xFF, 0xF3, 0x44, 0xC4]); // Fake MP3 sync word
      created++;
    }
  }

  print('Created $created placeholder files.');
}
