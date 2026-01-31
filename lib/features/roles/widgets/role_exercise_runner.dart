import 'package:flutter/material.dart';
import '../domain/role_model.dart';

class RoleExerciseRunner extends StatelessWidget {
  final RoleDialogue dialogue;
  final VoidCallback onComplete;

  const RoleExerciseRunner({
    super.key,
    required this.dialogue,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Role Exercises - Phase 4'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onComplete,
              child: const Text('Finish Debug'),
            ),
          ],
        ),
      ),
    );
  }
}
