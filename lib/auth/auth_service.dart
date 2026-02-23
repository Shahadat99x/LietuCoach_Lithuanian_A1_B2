/// Auth Service for Supabase Authentication
///
/// Handles Google OAuth sign-in, session management, and auth state.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Authentication state
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Auth state with user info
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  factory AuthState.unknown() => const AuthState(status: AuthStatus.unknown);
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  String? get displayName => user?.userMetadata?['full_name'] as String?;
  String? get email => user?.email;
  String? get avatarUrl => user?.userMetadata?['avatar_url'] as String?;
}

/// Auth service singleton
class AuthService extends ChangeNotifier {
  AuthState _state = AuthState.unknown();
  StreamSubscription<dynamic>? _authSubscription;
  bool _initialized = false;

  AuthState get state => _state;
  User? get currentUser => _state.user;
  bool get isAuthenticated => _state.isAuthenticated;

  /// Initialize Supabase and listen to auth changes
  Future<void> init() async {
    if (_initialized) {
      debugPrint(
        'Auth: init() called again, skipping duplicate initialization',
      );
      return;
    }

    if (!Env.isSupabaseConfigured) {
      debugPrint(
        'Auth: Supabase not configured (missing SUPABASE_URL or SUPABASE_ANON_KEY)',
      );
      _state = AuthState.unauthenticated();
      notifyListeners();
      return;
    }

    debugPrint(
      'Auth: initializing Supabase with Env URL=${Env.supabaseUrl}, anonKeyLen=${Env.supabaseAnonKey.length}',
    );

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    final runtimeClientUrl = Supabase.instance.client.rest.url.replaceFirst(
      RegExp(r'/rest/v1/?$'),
      '',
    );
    debugPrint('Auth: runtime client URL after init=$runtimeClientUrl');
    _initialized = true;

    // Listen to auth state changes — store subscription for cleanup
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      debugPrint(
        'Auth: [EVENT] event=${data.event}, hasSession=${data.session != null}',
      );
      final session = data.session;
      if (session != null) {
        _state = AuthState.authenticated(session.user);
        debugPrint(
          'Auth: [EVENT] user=${session.user.email}, provider=${session.user.appMetadata['provider']}',
        );
      } else {
        if (data.event == AuthChangeEvent.signedOut) {
          _state = AuthState.unauthenticated();
        }
        // Ignore tokenRefreshed/initialSession with null session
        // to avoid incorrectly clearing an active session.
      }
      notifyListeners();
      debugPrint(
        'Auth: [EVENT] notifyListeners() called, state=${_state.status}, '
        'hasListeners=$hasListeners',
      );
    });

    // Check initial session (may already be restored from local storage)
    final session = Supabase.instance.client.auth.currentSession;
    final currentUser = Supabase.instance.client.auth.currentUser;
    debugPrint(
      'Auth: [INIT] currentSession=${session != null}, '
      'currentUser=${currentUser?.email}, '
      'sessionExpiry=${session?.expiresAt}',
    );
    if (session != null) {
      _state = AuthState.authenticated(session.user);
    } else {
      _state = AuthState.unauthenticated();
    }
    notifyListeners();
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    if (!Env.isSupabaseConfigured) {
      debugPrint('Auth: Cannot sign in - Supabase not configured');
      return false;
    }

    try {
      debugPrint('Auth: [SIGN-IN] Starting Google sign-in...');
      // Reset error state
      if (_state.errorMessage != null) {
        _state = AuthState(
          status: _state.status,
          user: _state.user,
          errorMessage: null,
        );
        notifyListeners();
      }

      const redirectUrl = 'io.lietucoach.app://login-callback';
      debugPrint('Auth: [SIGN-IN] redirectTo=$redirectUrl');
      debugPrint(
        'Auth: [SIGN-IN] launching with inAppBrowserView (Custom Tab)',
      );

      final result = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );

      debugPrint('Auth: [SIGN-IN] signInWithOAuth returned: $result');

      if (!result) {
        // Should not happen as OAuth is a redirect flow,
        // but if it returns false immediately for some reason
        throw Exception('OAuth initiation failed');
      }

      // OAuth flow is async - state will update via onAuthStateChange
      // Add a small polling loop here for deterministic checking in release
      debugPrint('Auth: [SESSION] waiting up to 3s for session to manifest...');
      for (var i = 0; i < 12; i++) {
        await Future.delayed(const Duration(milliseconds: 250));
        final s = Supabase.instance.client.auth.currentSession;
        if (s != null) {
          debugPrint(
            'Auth: [SESSION] Session set after ${i * 250}ms! user=${s.user.email}',
          );
          // Force refresh state just in case
          _state = AuthState.authenticated(s.user);
          notifyListeners();
          return true;
        }
      }
      debugPrint('Auth: [SESSION] SESSION NOT SET after 3s polling!');

      return true;
    } catch (e, stack) {
      debugPrint('Auth: [SIGN-IN] ERROR: $e');
      debugPrint('Auth: [SIGN-IN] Stack: $stack');
      _state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage:
            'Sign in failed: ${e.toString().split('\n').first}', // Clean message
      );
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!Env.isSupabaseConfigured) return;

    try {
      await Supabase.instance.client.auth.signOut();
      debugPrint('Auth: Signed out');
    } catch (e) {
      debugPrint('Auth: Sign out failed: $e');
    } finally {
      _state = AuthState.unauthenticated();
      notifyListeners();
    }
  }

  @visibleForTesting
  void setAuthStateForTest(AuthState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Global auth service instance
final authService = AuthService();
