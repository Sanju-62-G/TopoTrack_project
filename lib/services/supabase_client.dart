import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  // Direct access to the Supabase client
  static final SupabaseClient client = Supabase.instance.client;

  // Shortcuts for commonly used features
  static GoTrueClient get auth => client.auth;
  
  // Get current user information
  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => auth.currentUser?.id;
  
  // Session management
  static Session? get currentSession => auth.currentSession;
  static bool get isLoggedIn => currentSession != null;

  // Database access helper
  static SupabaseQueryBuilder from(String table) => client.from(table);
}
