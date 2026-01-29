/// Path Screen - Course progression view with path map
///
/// Shows units, lessons progress, and exam gates.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../content/content.dart';
import '../../packs/packs.dart';
import '../../progress/progress.dart';
import '../certificate/certificate.dart';
import '../../auth/auth.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../lesson/lesson_list_screen.dart';
import '../exam/exam_intro_screen.dart';
import '../content/content_error_screen.dart';
import 'certificate_node.dart';
import '../../debug/debug_state.dart';

/// Course units configuration
/// In future this comes from a course manifest
const List<CourseUnitConfig> courseUnits = [
  CourseUnitConfig(
    unitId: 'unit_01',
    title: 'Greetings & Basics',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_02',
    title: 'Numbers & Counting',
    lessonCount: 2,
    hasContent: true,
  ),
];

class CourseUnitConfig {
  final String unitId;
  final String title;
  final int lessonCount;
  final bool hasContent;

  const CourseUnitConfig({
    required this.unitId,
    required this.title,
    required this.lessonCount,
    required this.hasContent,
  });
}

class PathScreen extends StatefulWidget {
  const PathScreen({super.key});

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  final _repository = ContentRepository();
  final Map<String, Unit> _units = {};
  final Map<String, int> _lessonCompletedCount = {};
  final Map<String, UnitProgress?> _unitProgress = {};
  final Map<String, bool> _unitAvailability = {};
  final Map<String, DownloadProgress?> _activeDownloads = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load progress for all units
    for (final config in courseUnits) {
      // Check if unit content is available (installed or assets)
      final isAvailable = await _repository.isUnitAvailable(config.unitId);
      _unitAvailability[config.unitId] = isAvailable;

      // Load unit content if available
      if (isAvailable && config.hasContent) {
        final result = await _repository.loadUnit(config.unitId);
        if (result.isSuccess) {
          _units[config.unitId] = result.value;
        }
      }

      // Load lesson progress
      final lessons = await progressStore.getUnitLessonProgress(config.unitId);
      _lessonCompletedCount[config.unitId] = lessons
          .where((l) => l.completed)
          .length;

      // Load unit progress (exam status)
      _unitProgress[config.unitId] = await progressStore.getUnitProgress(
        config.unitId,
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  bool _isUnitUnlocked(int index) {
    if (DebugState.forceUnlockContent.value) return true;
    if (index == 0) return true;

    // Use single source of truth from ProgressStore
    // We already fetch availability in _loadData, but ideally _unitAvailability
    // should be populated by calling progressStore.isUnitUnlocked for each unit?
    // Actually, _isUnitUnlocked is called during build.
    // Making it async would complicate build.

    // Better: Pre-fetch "isUnlocked" status in _loadData.
    // For now, let's keep the synchronous check if possible, OR
    // rely on the data we already fetched compatible with Store logic.

    // Store Logic: Unit N unlocked if Unit N-1 Exam Passed.
    final prevConfig = courseUnits[index - 1];
    final examPassed = _unitProgress[prevConfig.unitId]?.examPassed ?? false;

    // Note: We intentionally ignore lesson completion count here to match
    // the simplified rule in LocalProgressStore.
    return examPassed;
  }

  void _startDownload(String unitId) async {
    try {
      await _repository.downloadUnit(unitId);

      // Listen to progress
      _repository
          .downloadProgress(unitId)
          .listen(
            (progress) {
              if (!mounted) return;
              setState(() {
                _activeDownloads[unitId] = progress;
                if (progress.status == PackStatus.installed) {
                  _activeDownloads.remove(unitId);
                  _unitAvailability[unitId] = true;
                  _loadData(); // Reload content
                }
              });
            },
            onError: (e) {
              if (mounted) {
                _showDownloadError(unitId, 'Download failed: $e');
                setState(() => _activeDownloads.remove(unitId));
              }
            },
          );
    } catch (e) {
      if (mounted) {
        _showDownloadError(unitId, 'Check internet connection');
      }
    }
  }

  void _showDownloadError(String unitId, String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContentErrorScreen(
          title: 'Download Required',
          message:
              'This unit needs to be downloaded. Please check your internet connection.',
          onRetry: () {
            Navigator.of(context).pop();
            _startDownload(unitId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.pagePadding,
                    ),
                    child: Text(
                      'Learning Path',
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: Spacing.s),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.pagePadding,
                    ),
                    child: Text(
                      'A1 Level - Beginner',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.l),

                  // Units with exams
                  for (var i = 0; i < courseUnits.length; i++) ...[
                    _buildUnitSection(i),
                    if (i < courseUnits.length - 1)
                      const SizedBox(height: Spacing.m),
                  ],

                  if (_isCourseCompleted()) ...[
                    const SizedBox(height: Spacing.xl),
                    CertificateNode(onTap: () => _openCertificate()),
                    const SizedBox(height: Spacing.xxl),
                  ] else ...[
                    const SizedBox(height: Spacing.xxl),
                  ],
                ],
              ),
            ),
    );
  }

  bool _isCourseCompleted() {
    if (courseUnits.isEmpty) return false;
    final lastIndex = courseUnits.length - 1;
    final config = courseUnits[lastIndex];
    final completedCount = _lessonCompletedCount[config.unitId] ?? 0;
    final examPassed = _unitProgress[config.unitId]?.examPassed ?? false;
    return completedCount >= config.lessonCount && examPassed;
  }

  Future<void> _openCertificate() async {
    final service = CertificateService();
    await service.init();

    // Resolve current user details
    final user = authService.currentUser;
    final String resolvedName = user?.userMetadata?['full_name'] as String? ?? 
                       user?.email?.split('@')[0] ?? 
                       'Guest User';
    final String resolvedId = user?.id ?? 'guest_user';

    // Check if exists
    final certs = service.getCertificates();
    var cert = certs.isEmpty ? null : certs.first; // Simplified for MVP

    // Check if we need to regenerate (missing or name mismatch)
    final bool needsRegeneration = cert == null || cert.learnerName != resolvedName;

    if (needsRegeneration) {
      // Generate one
      await service.generateAndSaveCertificate(
        userName: resolvedName,
        userId: resolvedId,
        score: '100', // Mock score
      );
      // Reload after generation
      cert = service.getCertificates().first;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CertificateScreen(
          userName: cert!.learnerName,
          userId: resolvedId,
          date: cert.issuedAt,
          certificateId: cert.id,
        ),
      ),
    );
  }

  Widget _buildUnitSection(int index) {
    final config = courseUnits[index];
    final isUnlocked = _isUnitUnlocked(index);
    final unit = _units[config.unitId];
    final completedCount = _lessonCompletedCount[config.unitId] ?? 0;
    final unitProgress = _unitProgress[config.unitId];
    final allLessonsCompleted = completedCount >= config.lessonCount;

    final isAvailable = _unitAvailability[config.unitId] ?? false;
    final downloadProgress = _activeDownloads[config.unitId];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
      child: Column(
        children: [
          // Unit card
          _UnitCard(
            config: config,
            isUnlocked: isUnlocked,
            isAvailable: isAvailable,
            downloadProgress: downloadProgress,
            completedLessons: completedCount,
            examPassed: unitProgress?.examPassed ?? false,
            onTap: () {
              if (kDebugMode) {
                print(
                  'TAP unitId=${config.unitId} unlocked=$isUnlocked '
                  'available=$isAvailable padEnabled=${_repository.isPadEnabled}',
                );
              }

              if (!isUnlocked) {
                if (kDebugMode) print('TAP BLOCKED: Unit locked');
                return;
              }

              if (isAvailable) {
                _openUnitLessons(config.unitId);
              } else if (downloadProgress == null) {
                if (_repository.isPadEnabled) {
                  _startDownload(config.unitId);
                } else {
                  // If PAD disabled and not available, still try to open 
                  // to show "Coming soon" or error inside the target screen.
                  _openUnitLessons(config.unitId);
                }
              }
            },
          ),

          // Exam node (only for units with content)
          if (config.hasContent) ...[
            _PathConnector(),
            _ExamNode(
              unitId: config.unitId,
              isUnlocked: isUnlocked && allLessonsCompleted,
              examPassed: unitProgress?.examPassed ?? false,
              examScore: unitProgress?.examScore,
              onTap:
                  isUnlocked &&
                      allLessonsCompleted &&
                      !(unitProgress?.examPassed ?? false)
                  ? () => _openExam(unit!)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  void _openUnitLessons(String unitId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => LessonListScreen(unitId: unitId)),
        )
        .then((_) => _loadData()); // Refresh on return
  }

  void _openExam(Unit unit) async {
    final allLessons = await progressStore.getUnitLessonProgress(unit.id);
    final allCompleted =
        allLessons.where((l) => l.completed).length >=
        courseUnits.firstWhere((c) => c.unitId == unit.id).lessonCount;

    if (!mounted) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => UnitExamIntroScreen(
              unit: unit,
              allLessonsCompleted: allCompleted,
            ),
          ),
        )
        .then((_) => _loadData()); // Refresh on return
  }
}

class _UnitCard extends StatelessWidget {
  final CourseUnitConfig config;
  final bool isUnlocked;
  final bool isAvailable;
  final DownloadProgress? downloadProgress;
  final int completedLessons;
  final bool examPassed;
  final VoidCallback? onTap;

  const _UnitCard({
    required this.config,
    required this.isUnlocked,
    this.isAvailable = true,
    this.downloadProgress,
    required this.completedLessons,
    required this.examPassed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = completedLessons / config.lessonCount;

    return AppCard(
      onTap: onTap,
      color: isUnlocked ? null : theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          // Unit icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            alignment: Alignment.center,
            child: Icon(
              isUnlocked ? Icons.book : Icons.lock,
              size: 28,
              color: isUnlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: Spacing.m),

          // Unit info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isUnlocked
                        ? null
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                if (isUnlocked) ...[
                  ProgressBar(value: progress, height: 6),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    '$completedLessons of ${config.lessonCount} lessons',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else
                  Text(
                    'Complete previous unit to unlock',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Status indicator
          if (isUnlocked)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _PathConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(width: 2, height: 24, color: theme.dividerColor);
  }
}

class _ExamNode extends StatelessWidget {
  final String unitId;
  final bool isUnlocked;
  final bool examPassed;
  final int? examScore;
  final VoidCallback? onTap;

  const _ExamNode({
    required this.unitId,
    required this.isUnlocked,
    required this.examPassed,
    this.examScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String label;
    String? subtitle;

    if (examPassed) {
      backgroundColor = AppColors.successLight;
      iconColor = AppColors.success;
      icon = Icons.check_circle;
      label = 'Exam Passed';
      subtitle = examScore != null ? '$examScore%' : null;
    } else if (isUnlocked) {
      backgroundColor = theme.colorScheme.primaryContainer;
      iconColor = theme.colorScheme.primary;
      icon = Icons.quiz;
      label = 'Take Exam';
      subtitle = 'Pass to unlock next unit';
    } else {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      iconColor = theme.colorScheme.onSurfaceVariant;
      icon = Icons.lock;
      label = 'Unit Exam';
      subtitle = 'Complete all lessons first';
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: Spacing.s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: iconColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
