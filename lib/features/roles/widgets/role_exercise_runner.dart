import 'package:flutter/material.dart';
import '../../lesson/widgets/exercise_shell.dart';
import '../../lesson/widgets/bottom_result_sheet.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/tokens.dart';
import '../../../design_system/glass/glass.dart';
import '../domain/role_model.dart';
import 'role_mcq_widget.dart';
import 'role_reorder_widget.dart';

class RoleExerciseRunner extends StatefulWidget {
  final RoleDialogue dialogue;
  final VoidCallback onComplete;

  const RoleExerciseRunner({
    super.key,
    required this.dialogue,
    required this.onComplete,
  });

  @override
  State<RoleExerciseRunner> createState() => _RoleExerciseRunnerState();
}

class _RoleExerciseRunnerState extends State<RoleExerciseRunner> {
  int _currentIndex = 0;
  bool _hasAnswered = false;
  bool _isAnswerCorrect = false; // Track locally for current step

  // State for inputs
  int? _selectedMcqIndex;
  List<String> _selectedReorder = [];

  List<RoleExercise> get _exercises => widget.dialogue.exercises;

  void _onCheck() {
    final exercise = _exercises[_currentIndex];
    bool correct = false;

    if (exercise.type == 'mcq') {
      if (_selectedMcqIndex == null) return;
      correct = _selectedMcqIndex == exercise.correctIndex;
    } else if (exercise.type == 'reorder') {
      if (_selectedReorder.isEmpty) return;
      // Compare lists
      final expected = exercise.correctSequence ?? [];
      if (_selectedReorder.length == expected.length) {
        correct = true;
        for (int i = 0; i < expected.length; i++) {
          if (_selectedReorder[i] != expected[i]) {
            correct = false;
            break;
          }
        }
      }
    }

    setState(() {
      _hasAnswered = true;
      _isAnswerCorrect = correct;
    });
  }

  void _onContinue() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _hasAnswered = false;
        _isAnswerCorrect = false;
        _selectedMcqIndex = null;
        _selectedReorder = [];
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      // Degrade gracefully if no exercises
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onComplete());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final exercise = _exercises[_currentIndex];
    final progress = (_currentIndex + 1) / _exercises.length;

    return ExerciseShell(
      progress: progress,
      title: widget.dialogue.title,
      onClose: () => Navigator.of(context).pop(),
      content: _buildContent(exercise),
      footer: _buildFooter(context),
    );
  }

  Widget _buildContent(RoleExercise exercise) {
    if (exercise.type == 'mcq') {
      return RoleMcqWidget(
        exercise: exercise,
        selectedIndex: _selectedMcqIndex,
        hasAnswered: _hasAnswered,
        onSelect: (index) {
          setState(() => _selectedMcqIndex = index);
        },
      );
    } else if (exercise.type == 'reorder') {
      return RoleReorderWidget(
        exercise: exercise,
        hasAnswered: _hasAnswered,
        onOrderChanged: (order) {
          setState(() => _selectedReorder = order); // Just store, don't check
        },
      );
    }
    return Text('Unknown type: ${exercise.type}');
  }

  Widget? _buildFooter(BuildContext context) {
    if (_hasAnswered) {
      return BottomResultSheet(
        state: _isAnswerCorrect ? ResultState.correct : ResultState.incorrect,
        title: _isAnswerCorrect ? 'Correct!' : 'Incorrect',
        message: _isAnswerCorrect ? 'Well done.' : 'Review the answer above.',
        onContinue: _onContinue,
      );
    }

    // Check Button
    bool canCheck = false;
    final exercise = _exercises[_currentIndex];
    if (exercise.type == 'mcq') {
      canCheck = _selectedMcqIndex != null;
    } else if (exercise.type == 'reorder') {
      canCheck = _selectedReorder.isNotEmpty;
    }

    return GlassSurface(
      preset: GlassPreset.solid,
      padding: const EdgeInsets.fromLTRB(
        AppSemanticSpacing.space12,
        AppSemanticSpacing.space8,
        AppSemanticSpacing.space12,
        AppSemanticSpacing.space8,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSemanticSpacing.space4),
        child: PrimaryButton(
          label: 'CHECK',
          onPressed: canCheck ? _onCheck : null,
          isFullWidth: true,
        ),
      ),
    );
  }
}
