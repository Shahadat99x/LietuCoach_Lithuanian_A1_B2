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
import '../../ui/components/components.dart';
import '../lesson/lesson_list_screen.dart';
import '../exam/exam_intro_screen.dart';
import '../content/content_error_screen.dart';
import 'certificate_node.dart';
import '../../debug/debug_state.dart';
import 'widgets/path_header.dart';
import 'widgets/segmented_view_toggle.dart';

import 'widgets/path_list_view.dart';
import 'widgets/path_map_view.dart';
import 'models/course_unit_config.dart';
import 'services/path_preferences_service.dart';

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
  CourseUnitConfig(
    unitId: 'unit_03',
    title: 'Introductions 2',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_04',
    title: 'Personal Info',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_05',
    title: 'Family & People',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_06',
    title: 'Days & Time',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_07',
    title: 'Food Basics',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_08',
    title: 'Directions',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_09',
    title: 'Shopping',
    lessonCount: 2,
    hasContent: true,
  ),
  CourseUnitConfig(
    unitId: 'unit_10',
    title: 'Weather',
    lessonCount: 2,
    hasContent: true,
  ),
];

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

  PathStyle _pathStyle = PathStyle.list;

  @override
  void initState() {
    super.initState();
    _loadData(); // existing data load
    // _loadPreference(); // Will be enabled in next commit
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
    // Find last active unit for "Continue" button
    CourseUnitConfig? continueUnit;
    for (final config in courseUnits) {
      final isUnlocked = _isUnitUnlocked(courseUnits.indexOf(config));
      final completed = _lessonCompletedCount[config.unitId] ?? 0;
      final unitProgress = _unitProgress[config.unitId];
      final isFinished =
          completed >= config.lessonCount &&
          (unitProgress?.examPassed ?? false);

      if (isUnlocked && !isFinished) {
        continueUnit = config;
        break;
      }
    }
    continueUnit ??= courseUnits.first;

    final header = PathHeader(
      onContinue: () {
        if (continueUnit != null) {
          _openUnitLessons(continueUnit.unitId);
        }
      },
      continueLabel: 'Continue ${continueUnit.title}',
      continueSubLabel: 'Unit ${courseUnits.indexOf(continueUnit) + 1}',
      trailing: SegmentedViewToggle(
        isMap: _pathStyle == PathStyle.map,
        onToggle: (isMap) async {
          final newStyle = isMap ? PathStyle.map : PathStyle.list;
          if (newStyle != _pathStyle) {
            setState(() => _pathStyle = newStyle);
            await PathPreferencesService().setPathStyle(newStyle);
          }
        },
      ),
    );

    final footer = _isCourseCompleted()
        ? CertificateNode(onTap: () => _openCertificate())
        : null;

    final child = _pathStyle == PathStyle.list
        ? PathListView(
            courseUnits: courseUnits,
            isUnitUnlocked: _isUnitUnlocked,
            lessonCompletedCount: _lessonCompletedCount,
            unitProgress: _unitProgress,
            unitAvailability: _unitAvailability,
            activeDownloads: _activeDownloads,
            onUnitTap: (config) => _handleUnitTap(config),
            onExamTap: (config) => _handleExamTap(config),
            header: header,
            footer: footer,
          )
        : PathMapView(
            courseUnits: courseUnits,
            isUnitUnlocked: _isUnitUnlocked,
            lessonCompletedCount: _lessonCompletedCount,
            unitProgress: _unitProgress,
            unitAvailability: _unitAvailability,
            activeDownloads: _activeDownloads,
            onUnitTap: (config) => _handleUnitTap(config),
            onExamTap: (config) => _handleExamTap(config),
            header: header,
            footer: footer,
          );

    return AppScaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _loadData, child: child),
    );
  }

  void _handleUnitTap(CourseUnitConfig config) {
    final isUnlocked = _isUnitUnlocked(courseUnits.indexOf(config));
    final isAvailable = _unitAvailability[config.unitId] ?? false;
    final downloadProgress = _activeDownloads[config.unitId];

    if (kDebugMode) {
      print(
        'TAP unitId=${config.unitId} unlocked=$isUnlocked available=$isAvailable',
      );
    }

    if (!isUnlocked) return;

    if (isAvailable) {
      _openUnitLessons(config.unitId);
    } else if (downloadProgress == null) {
      if (_repository.isPadEnabled) {
        _startDownload(config.unitId);
      } else {
        _openUnitLessons(config.unitId);
      }
    }
  }

  void _handleExamTap(CourseUnitConfig config) {
    final isAvailable = _unitAvailability[config.unitId] ?? false;
    if (isAvailable) {
      final result = _units[config.unitId];
      if (result != null) _openExam(result);
    }
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
    final String resolvedName =
        user?.userMetadata?['full_name'] as String? ??
        user?.email?.split('@')[0] ??
        'Guest User';
    final String resolvedId = user?.id ?? 'guest_user';

    // Check if exists
    final certs = service.getCertificates();
    var cert = certs.isEmpty ? null : certs.first; // Simplified for MVP

    // Check if we need to regenerate (missing or name mismatch)
    final bool needsRegeneration =
        cert == null || cert.learnerName != resolvedName;

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
