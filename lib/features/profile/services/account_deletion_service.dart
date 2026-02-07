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
  static const bool _debugJwtGatewayToggleHint = true;

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
      final session = await _resolveSession(client);
      if (kDebugMode) {
        final token = session?.accessToken ?? '';
        debugPrint('Account deletion: runtime SUPABASE_URL=${Env.supabaseUrl}');
        debugPrint('Account deletion: session exists=${session != null}');
        debugPrint(
          'Account deletion: jwtParts=${token.isEmpty ? 0 : token.split('.').length}, tokenLength=${token.length}',
        );
      }

      if (session?.accessToken.isEmpty ?? true) {
        return AccountDeletionResult.failure(
          'Not authenticated. Please sign in again and retry.',
        );
      }

      debugPrint('Account deletion: invoking delete-account...');
      final response = await client.functions.invoke('delete-account');
      final data = response.data;
      debugPrint(
        'Account deletion response: status=${response.status}, body=$data',
      );

      if (kDebugMode && _debugJwtGatewayToggleHint && response.status == 401) {
        debugPrint(
          'Account deletion debug hint: if this is a gateway-level Invalid JWT, temporarily disable Verify JWT in Supabase Dashboard > Edge Functions > delete-account, retest, then re-enable immediately.',
        );
      }

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
    } catch (e, st) {
      debugPrint('Account deletion failed: $e');
      debugPrintStack(stackTrace: st);
      return AccountDeletionResult.failure(
        'Delete failed. Please try again or contact hello@dhossain.com.',
      );
    }
  }

  String _extractError(dynamic data, {required String fallback}) {
    if (data is Map) {
      final rawMessage = switch (data['message']) {
        final String value => value.trim(),
        _ => switch (data['error']) {
          final String value => value.trim(),
          _ => '',
        },
      };
      final step = data['step'] is String
          ? (data['step'] as String).trim()
          : '';
      final requestId = data['requestId'] is String
          ? (data['requestId'] as String).trim()
          : '';

      if (requestId.isNotEmpty) {
        debugPrint('Account deletion requestId: $requestId');
      }

      final message = rawMessage.isEmpty ? fallback : rawMessage;
      if (step.isNotEmpty) {
        return '$message (step: $step)';
      }
      return message;
    }
    return fallback;
  }

  Future<Session?> _resolveSession(SupabaseClient client) async {
    final current = client.auth.currentSession;
    if (current != null) return current;

    try {
      final refreshed = await client.auth.refreshSession();
      return refreshed.session;
    } catch (e) {
      debugPrint('Account deletion: session refresh failed: $e');
      return null;
    }
  }
}
