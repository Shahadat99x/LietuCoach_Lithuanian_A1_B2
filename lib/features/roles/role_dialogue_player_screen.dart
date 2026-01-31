import 'package:flutter/material.dart';
import 'domain/role_model.dart';

class RoleDialoguePlayerScreen extends StatelessWidget {
  final RoleDialogue dialogue;
  final RolePack pack;

  const RoleDialoguePlayerScreen({
    super.key,
    required this.dialogue,
    required this.pack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dialogue.title)),
      body: const Center(child: Text('Dialogue Player - Phase 3')),
    );
  }
}
