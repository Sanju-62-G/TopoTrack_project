import 'supabase_client.dart';

class CareerService {
  // User এর career goal + skills fetch করো
  static Future<Map<String, dynamic>> getCareerData() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return {'skills': [], 'career_goal': null};

    // User এর career goal fetch করো
    final userData = await SupabaseClientService.from('users')
        .select('career_goal, selected_goal')
        .eq('id', userId)
        .maybeSingle();

    if (userData == null) return {'skills': [], 'career_goal': null};

    final String? careerGoal = userData['career_goal'];

    if (careerGoal == null) return {'skills': [], 'career_goal': null};

    // Skills + user progress একসাথে fetch করো
    // Note: Assuming 'career_skills' table exists with these columns
    final skills = await SupabaseClientService.from('career_skills')
        .select('''
          *,
          user_skill_progress(
            is_completed,
            progress_percent
          )
        ''')
        .eq('career_goal', careerGoal)
        .order('order_index', ascending: true);

    return {
      'career_goal': careerGoal,
      'selected_goal': userData['selected_goal'],
      'skills': List<Map<String, dynamic>>.from(skills),
    };
  }

  // Skill progress update করো
  static Future<void> updateSkillProgress({
    required String skillId,
    required int progressPercent,
    required bool isCompleted,
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    await SupabaseClientService.from('user_skill_progress')
        .upsert({
          'user_id': userId,
          'skill_id': skillId,
          'progress_percent': progressPercent,
          'is_completed': isCompleted,
        });
  }

  // Overall readiness % calculate করো
  static double calculateReadiness(List<Map<String, dynamic>> skills) {
    if (skills.isEmpty) return 0;

    double total = 0;
    for (var skill in skills) {
      final progressList = skill['user_skill_progress'];
      if (progressList != null && (progressList as List).isNotEmpty) {
        total += (progressList[0]['progress_percent'] as num).toDouble();
      }
    }

    return (total / (skills.length * 100)) * 100;
  }

  // Career goal label বানাও
  static String getCareerLabel(String careerGoal) {
    Map<String, String> labels = {
      'flutter_developer': 'Flutter Developer',
      'web_developer': 'Web Developer',
      'full_stack_developer': 'Full Stack Developer',
      'android_developer': 'Android Developer',
      'backend_developer': 'Backend Developer',
      'software_engineer': 'Software Engineer',
      'game_developer': 'Game Developer',
      'devops_engineer': 'DevOps Engineer',
      'cloud_engineer': 'Cloud Engineer',
      'blockchain_developer': 'Blockchain Developer',
      'cybersecurity_analyst': 'Cybersecurity Analyst',
      'network_engineer': 'Network Engineer',
      'database_administrator': 'Database Administrator',
      'ui_ux_designer': 'UI/UX Designer',
      'data_scientist': 'Data Scientist',
      'data_engineer': 'Data Engineer',
      'ai_ml_engineer': 'AI/ML Engineer',
      'researcher_phd': 'Researcher / PhD',
      'university_lecturer': 'University Lecturer',
    };
    return labels[careerGoal] ?? careerGoal;
  }
}
