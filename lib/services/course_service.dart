import 'supabase_client.dart';

class CourseService {
  // Course add করো
  static Future<void> addCourse({
    required String name,
    required String courseCode,
    required double creditHours,
    required String semester,
    String? teacherName,
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await SupabaseClientService.from('courses').insert({
      'user_id': userId,
      'name': name,
      'course_code': courseCode,
      'credit_hours': creditHours,
      'semester': semester,
      'teacher_name': teacherName,
    });
  }

  // সব courses fetch করো
  static Future<List<Map<String, dynamic>>> getCourses() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseClientService.from('courses')
        .select()
        .eq('user_id', userId)
        .order('semester', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  // Semester অনুযায়ী courses fetch করো
  static Future<List<Map<String, dynamic>>> getCoursesBySemester(
    String semester,
  ) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseClientService.from('courses')
        .select()
        .eq('user_id', userId)
        .eq('semester', semester)
        .order('credit_hours', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Single course fetch করো
  static Future<Map<String, dynamic>?> getCourse(String courseId) async {
    return await SupabaseClientService.from('courses')
        .select()
        .eq('id', courseId)
        .maybeSingle();
  }

  // Course update করো
  static Future<void> updateCourse({
    required String courseId,
    required String name,
    required String courseCode,
    required double creditHours,
    required String semester,
    String? teacherName,
  }) async {
    await SupabaseClientService.from('courses').update({
      'name': name,
      'course_code': courseCode,
      'credit_hours': creditHours,
      'semester': semester,
      'teacher_name': teacherName,
    }).eq('id', courseId);
  }

  // Course delete করো
  static Future<void> deleteCourse(String courseId) async {
    await SupabaseClientService.from('courses')
        .delete()
        .eq('id', courseId);
  }
}
