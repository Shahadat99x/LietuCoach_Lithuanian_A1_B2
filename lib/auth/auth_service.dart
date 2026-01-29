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
  StreamSubscription<AuthState>? _authSubscription;

  AuthState get state => _state;
  User? get currentUser => _state.user;
  bool get isAuthenticated => _state.isAuthenticated;

  /// Initialize Supabase and listen to auth changes
  Future<void> init() async {
    if (!Env.isSupabaseConfigured) {
      debugPrint(
        'Auth: Supabase not configured (missing SUPABASE_URL or SUPABASE_ANON_KEY)',
      );
      _state = AuthState.unauthenticated();
      notifyListeners();
      return;
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _state = AuthState.authenticated(session.user);
      } else {
        _state = AuthState.unauthenticated();
      }
      notifyListeners();
      debugPrint('Auth: State changed to ${_state.status}');
    });

    // Check initial session
    final session = Supabase.instance.client.auth.currentSession;
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
      debugPrint('Auth: Starting Google sign-in...');
      // Reset error state
      if (_state.errorMessage != null) {
          _state = AuthState(
            status: _state.status,
            user: _state.user,
            errorMessage: null
          );
          notifyListeners();
      }

      final result = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.lietucoach.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
      if (!result) {
         // Should not happen as OAuth is a redirect flow, 
         // but if it returns false immediately for some reason
         throw Exception('OAuth initiation failed');
      }

      // OAuth flow is async - state will update via onAuthStateChange
      return true;
    } catch (e) {
      debugPrint('Auth: Google sign-in failed: $e');
      _state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign in failed: ${e.toString().split('\n').first}', // Clean message
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
      _state = AuthState.unauthenticated();
      notifyListeners();
      debugPrint('Auth: Signed out');
    } catch (e) {
      debugPrint('Auth: Sign out failed: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Global auth service instance
final authService = AuthService();
