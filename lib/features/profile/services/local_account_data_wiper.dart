import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/certificate/certificate_repository.dart';
import '../../../progress/progress.dart';
import '../../../srs/srs.dart';
import '../../../sync/sync_service.dart';
import '../../roles/service/role_progress_service.dart';

class LocalAccountDataWiper {
  LocalAccountDataWiper({
    ProgressStore? progress,
    SrsStore? srs,
    CertificateRepository? certificateRepository,
    SyncService? sync,
    RoleProgressService? roleProgress,
    Future<SharedPreferences> Function()? prefsProvider,
  }) : _progress = progress ?? progressStore,
       _srs = srs ?? srsStore,
       _certificateRepository =
           certificateRepository ?? CertificateRepository(),
       _sync = sync ?? syncService,
       _roleProgress = roleProgress ?? roleProgressService,
       _prefsProvider = prefsProvider ?? SharedPreferences.getInstance;

  final ProgressStore _progress;
  final SrsStore _srs;
  final CertificateRepository _certificateRepository;
  final SyncService _sync;
  final RoleProgressService _roleProgress;
  final Future<SharedPreferences> Function() _prefsProvider;

  Future<List<String>> wipeAfterAccountDeletion() async {
    final warnings = <String>[];

    Future<void> runStep(String label, Future<void> Function() action) async {
      try {
        await action();
      } catch (e) {
        warnings.add(label);
        debugPrint('Account deletion local wipe failed [$label]: $e');
      }
    }

    await runStep('progress', () => _progress.clearAll());
    await runStep('srs_cards', () => _srs.clearAll());

    await runStep('certificates', () async {
      await _certificateRepository.init();
      await _certificateRepository.clearAll();
    });

    await runStep('sync_meta', () => _sync.resetLocalSyncMeta());
    await runStep('roles_prefs', () => _roleProgress.clearAll());

    await runStep('onboarding_flag', () async {
      final prefs = await _prefsProvider();
      await prefs.setBool('seen_onboarding', false);
    });

    return warnings;
  }
}
