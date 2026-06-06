import 'package:flutter/foundation.dart';
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

  // Check if email exists in users table
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await SupabaseClientService.from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Error checking email: $e');
      return false;
    }
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

    try {
      // 1. First, find all topics to delete their prerequisites
      // This is necessary because topic_prerequisites doesn't have a user_id
      final topicsData = await SupabaseClientService.from('topics')
          .select('id')
          .eq('user_id', userId);
      
      final List<dynamic> topicIds = topicsData.map((t) => t['id']).toList();

      if (topicIds.isNotEmpty) {
        // Delete prerequisites associated with these topics
        // We delete where either topic_id or prerequisite_id is one of our topics
        await SupabaseClientService.from('topic_prerequisites')
            .delete()
            .inFilter('topic_id', topicIds);
            
        await SupabaseClientService.from('topic_prerequisites')
            .delete()
            .inFilter('prerequisite_id', topicIds);
      }

      // 2. Delete all user-specific data from other tables
      // (This handles cases where ON DELETE CASCADE might not be set in the database)
      await SupabaseClientService.from('user_skill_progress').delete().eq('user_id', userId);
      await SupabaseClientService.from('deadlines').delete().eq('user_id', userId);
      await SupabaseClientService.from('topics').delete().eq('user_id', userId);
      await SupabaseClientService.from('courses').delete().eq('user_id', userId);

      // 3. Delete the user profile from 'users' table
      await SupabaseClientService.from('users').delete().eq('id', userId);

      // 4. Sign out the user
      // Note: This only signs out the user. To fully delete the Auth account, 
      // a Supabase Edge Function or Database Trigger is typically required 
      // as users cannot delete their own Auth account directly via the client SDK.
      await signOut();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow; // Rethrow to show error in UI
    }
  }
}
