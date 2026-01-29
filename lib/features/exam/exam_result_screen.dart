/// Exam Result Screen
///
/// Shows exam score and pass/fail status.

import 'package:flutter/material.dart';
import '../../content/content.dart';
import '../../progress/progress.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../../auth/auth.dart';
import '../../features/certificate/certificate.dart';

/// Pass threshold for unit exams
const int examPassThreshold = 80;

class ExamResultScreen extends StatefulWidget {
  final Unit unit;
  final int score;
  final int correctCount;
  final int totalCount;

  const ExamResultScreen({
    super.key,
    required this.unit,
    required this.score,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  bool _saving = true;

  bool get _passed => widget.score >= examPassThreshold;

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    if (_passed) {
      // Save unit progress
      final progress = UnitProgress(
        unitId: widget.unit.id,
        examPassed: true,
        examScore: widget.score,
        examPassedAt: DateTime.now(),
      );
      await progressStore.saveUnitProgress(progress);
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: Spacing.xl),

              // Result icon
              Container(
                padding: const EdgeInsets.all(Spacing.l),
                decoration: BoxDecoration(
                  color: _passed
                      ? AppColors.successLight
                      : AppColors.dangerLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _passed ? Icons.celebration : Icons.refresh,
                  size: 64,
                  color: _passed ? AppColors.success : AppColors.danger,
                ),
              ),
              const SizedBox(height: Spacing.l),

              // Result text
              Text(
                _passed ? 'Congratulations!' : 'Keep Practicing',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.s),
              Text(
                _passed
                    ? 'You passed the ${widget.unit.title} exam!'
                    : 'You need 80% to pass. Try again!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),

              // Score card
              AppCard(
                child: Column(
                  children: [
                    Text(
                      '${widget.score}%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: _passed ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.s),
                    Text(
                      '${widget.correctCount} of ${widget.totalCount} correct',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Spacing.m),
                    LinearProgressIndicator(
                      value: widget.score / 100,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        _passed ? AppColors.success : AppColors.danger,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(Radii.full),
                    ),
                    const SizedBox(height: Spacing.s),
                    Text(
                      'Pass: $examPassThreshold%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (_passed && widget.unit.id == 'unit_01') ...[
                const SizedBox(height: Spacing.l),
                SecondaryButton(
                  label: 'Share/Save Certificate',
                  icon: Icons.workspace_premium,
                  onPressed: () => _downloadCertificate(context),
                ),
              ],

              if (_passed) ...[
                const SizedBox(height: Spacing.l),
                AppCard(
                  color: AppColors.successLight,
                  child: Row(
                    children: [
                      Icon(Icons.lock_open, color: AppColors.success),
                      const SizedBox(width: Spacing.m),
                      Expanded(
                        child: Text(
                          'Next unit unlocked!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Action buttons
              if (_saving)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: _passed ? 'Continue' : 'Try Again',
                    onPressed: () {
                      // Pop back to path screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
              const SizedBox(height: Spacing.m),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadCertificate(BuildContext context) async {
    setState(() => _saving = true);

    try {
      final service = CertificateService();
      await service.init();

      // Resolve user details
      final user = authService.currentUser;
      final String userName = user?.userMetadata?['full_name'] as String? ?? 
                       user?.email?.split('@')[0] ?? 
                       'Guest User';
      final String userId = user?.id ?? 'guest_user';

      final path = await service.generateAndSaveCertificate(
        userName: userName,
        userId: userId,
        score: widget.score.toString(),
      );

      if (!context.mounted) return;

      // Show snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Certificate ready')));

      // Open viewer
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CertificateScreen(
            userName: userName,
            userId: userId,
            date: DateTime.now(),
            certificateId: path!.split('/').last.replaceAll('.pdf', ''),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating certificate: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
