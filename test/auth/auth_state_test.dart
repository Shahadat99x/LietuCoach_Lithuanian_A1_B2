import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/auth/auth_service.dart' as local_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';

// Fake User
class FakeUser extends User {
  FakeUser()
      : super(
          id: '123',
          appMetadata: {},
          userMetadata: {'full_name': 'Test User'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: 'test@example.com',
        );
}

void main() {
  group('AuthState', () {
    test('unknown factory returns unknown status', () {
      final state = local_auth.AuthState.unknown();
      expect(state.status, local_auth.AuthStatus.unknown);
      expect(state.isAuthenticated, false);
    });

    test('authenticated factory returns authenticated status', () {
      final user = FakeUser();
      final state = local_auth.AuthState.authenticated(user);
      expect(state.status, local_auth.AuthStatus.authenticated);
      expect(state.isAuthenticated, true);
      expect(state.user, user);
      expect(state.displayName, 'Test User');
    });

    test('unauthenticated factory returns unauthenticated status', () {
      final state = local_auth.AuthState.unauthenticated();
      expect(state.status, local_auth.AuthStatus.unauthenticated);
      expect(state.isAuthenticated, false);
    });
  });

  // Note: AuthService tests require mocking Supabase static instance which is difficult without a wrapper.
  // We rely on manual verification for the actual signIn flow.
}
