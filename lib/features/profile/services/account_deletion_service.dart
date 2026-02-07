import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/auth.dart';
import '../../../config/env.dart';
import 'local_account_data_wiper.dart';

class AccountDeletionResult {
  const AccountDeletionResult({
    required this.ok,
    this.errorMessage,
    this.localWarnings = const <String>[],
  });

  final bool ok;
  final String? errorMessage;
  final List<String> localWarnings;

  factory AccountDeletionResult.success({
    List<String> localWarnings = const [],
  }) {
    return AccountDeletionResult(ok: true, localWarnings: localWarnings);
  }

  factory AccountDeletionResult.failure(String message) {
    return AccountDeletionResult(ok: false, errorMessage: message);
  }
}

class AccountDeletionService {
  AccountDeletionService({
    AuthService? auth,
    LocalAccountDataWiper? wiper,
    SupabaseClient? client,
  }) : _auth = auth ?? authService,
       _wiper = wiper ?? LocalAccountDataWiper(),
       _client = client;

  final AuthService _auth;
  final LocalAccountDataWiper _wiper;
  final SupabaseClient? _client;

  Future<AccountDeletionResult> deleteCurrentAccount({
    bool attemptedReauth = false,
  }) async {
    if (!Env.isSupabaseConfigured) {
      return AccountDeletionResult.failure(
        'Cloud account deletion is unavailable right now.',
      );
    }
    if (!_auth.isAuthenticated) {
      return AccountDeletionResult.failure('You are not signed in.');
    }

    try {
      if (attemptedReauth) {
        debugPrint('Account deletion: user attempted re-auth before deletion.');
      }

      final client = _client ?? Supabase.instance.client;
      final response = await client.functions.invoke('delete-account');
      final data = response.data;

      if (response.status != 200) {
        final safeMessage = _extractError(
          data,
          fallback: 'We could not delete your account. Please try again.',
        );
        return AccountDeletionResult.failure(safeMessage);
      }

      if (data is! Map || data['ok'] != true) {
        final safeMessage = _extractError(
          data,
          fallback: 'We could not delete your account. Please try again.',
        );
        return AccountDeletionResult.failure(safeMessage);
      }

      await _auth.signOut();
      final warnings = await _wiper.wipeAfterAccountDeletion();
      return AccountDeletionResult.success(localWarnings: warnings);
    } catch (e) {
      debugPrint('Account deletion failed: $e');
      return AccountDeletionResult.failure(
        'Delete failed. Please try again or contact hello@dhossain.com.',
      );
    }
  }

  String _extractError(dynamic data, {required String fallback}) {
    if (data is Map && data['error'] is String) {
      final message = (data['error'] as String).trim();
      if (message.isNotEmpty) return message;
    }
    return fallback;
  }
}
