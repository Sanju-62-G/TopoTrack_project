import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static bool isLoggedIn() => SupabaseClientService.isLoggedIn;

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await SupabaseClientService.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String department,
    required String semester,
  }) async {
    final response = await SupabaseClientService.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'student_id': studentId,
        'department': department,
        'semester': semester,
      },
    );

    if (response.user != null) {
      // Create user record in 'users' table using common client
      await SupabaseClientService.from('users').upsert({
        'id': response.user!.id,
        'full_name': fullName,
        'student_id': studentId,
        'department': department,
        'semester': semester,
        'email': email,
      });
    }

    return response;
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    await SupabaseClientService.auth.resetPasswordForEmail(email);
  }

  // Sign out
  Future<void> signOut() async {
    await SupabaseClientService.auth.signOut();
  }

  User? get currentUser => SupabaseClientService.currentUser;
  Session? get currentSession => SupabaseClientService.currentSession;
  bool get isAuthenticated => SupabaseClientService.isLoggedIn;

  Future<void> updateProfile({
    required String fullName,
    required String studentId,
    required String department,
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) throw Exception('No user logged in');

    await SupabaseClientService.from('users').update({
      'full_name': fullName,
      'student_id': studentId,
      'department': department,
    }).eq('id', userId);
  }

  // Get current user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return null;
    
    return await SupabaseClientService.from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  // Update selected goal
  Future<void> updateGoal(String goal) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    await SupabaseClientService.from('users').update({
      'selected_goal': goal,
    }).eq('id', userId);
  }

  // Delete current user account and profile
  Future<void> deleteAccount() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    await SupabaseClientService.from('users').delete().eq('id', userId);
    await signOut();
  }
}
