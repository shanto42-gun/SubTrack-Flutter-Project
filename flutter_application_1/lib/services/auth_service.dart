import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService({SupabaseClient? client}) : _supabase = client ?? supabase;

  /// Stream of authentication state changes (login, logout, token refresh)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Currently authenticated user, if any
  User? get currentUser => _supabase.auth.currentUser;

  /// Current active session, if any
  Session? get currentSession => _supabase.auth.currentSession;

  /// Whether a user is currently signed in
  bool get isAuthenticated => currentUser != null;

  /// Current user ID
  String? get currentUserId => currentUser?.id;

  /// Current user Email
  String? get currentUserEmail => currentUser?.email;

  /// Sign up with email, password, and optional full name
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: fullName != null && fullName.trim().isNotEmpty
          ? {'full_name': fullName.trim()}
          : null,
    );
    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  /// Sign out current session
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }
}
