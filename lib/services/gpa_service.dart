import 'supabase_client.dart';

class GpaService {
  // User এর current + target CGPA fetch করো
  static Future<Map<String, dynamic>?> getCgpaData() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return null;

    final data = await SupabaseClientService.from('users')
        .select('current_cgpa, target_cgpa, semester')
        .eq('id', userId)
        .maybeSingle();

    return data;
  }

  // Current semester এর courses fetch করো
  static Future<List<Map<String, dynamic>>> getCurrentCourses() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return [];

    // User এর current semester fetch করো
    final userData = await SupabaseClientService.from('users')
        .select('semester')
        .eq('id', userId)
        .maybeSingle();

    if (userData == null) return [];

    final String currentSemester = userData['semester'] ?? 'Semester 1';

    // Current semester এর courses fetch করো
    final courses = await SupabaseClientService.from('courses')
        .select()
        .eq('user_id', userId)
        .eq('semester', currentSemester)
        .order('credit_hours', ascending: false);

    return List<Map<String, dynamic>>.from(courses);
  }

  // GPA simulate করো
  static double simulateGpa({
    required List<Map<String, dynamic>> courses,
    required Map<String, double> targetGrades,
    required double currentCgpa,
    required int completedCredits,
  }) {
    double newPoints = 0;
    double newCredits = 0;

    for (var course in courses) {
      String courseId = course['id'].toString();
      double creditHours = (course['credit_hours'] as num).toDouble();
      double grade = targetGrades[courseId] ?? 0.0;

      newPoints += grade * creditHours;
      newCredits += creditHours;
    }

    // Previous semesters + current semester combine করো
    double totalPoints = (currentCgpa * completedCredits) + newPoints;
    double totalCredits = completedCredits.toDouble() + newCredits;

    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  // Grade point convert করো
  static double gradeToPoint(String grade) {
    switch (grade) {
      case 'A+': return 4.0;
      case 'A':  return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B':  return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C':  return 2.0;
      case 'D':  return 1.0;
      case 'F':  return 0.0;
      default:   return 0.0;
    }
  }

  // CGPA update করো
  static Future<void> updateCurrentCgpa(double newCgpa) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    await SupabaseClientService.from('users')
        .update({'current_cgpa': newCgpa})
        .eq('id', userId);
  }
}
