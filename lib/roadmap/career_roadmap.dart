import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../services/career_service.dart';

class CareerRoadmap extends StatefulWidget {
  const CareerRoadmap({super.key});

  @override
  State<CareerRoadmap> createState() => _CareerRoadmapState();
}

class _CareerRoadmapState extends State<CareerRoadmap> {
  Map<String, dynamic> _careerData = {};
  List<Map<String, dynamic>> _mustHave = [];
  List<Map<String, dynamic>> _goodToHave = [];
  double _readiness = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCareerData();
  }

  Future<void> _loadCareerData() async {
    try {
      final data = await CareerService.getCareerData();
      final List<Map<String, dynamic>> skills = 
          List<Map<String, dynamic>>.from(data['skills'] ?? []);

      setState(() {
        _careerData = data;
        _mustHave = skills
            .where((s) => s['category'] == 'must_have')
            .toList();
        _goodToHave = skills
            .where((s) => s['category'] == 'good_to_have')
            .toList();
        _readiness = CareerService.calculateReadiness(skills);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading career data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)));
    }

    if (_careerData['career_goal'] == null) {
      return _buildNoCareerGoal();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadinessCard(),
        SizedBox(height: 24.h),
        if (_mustHave.isNotEmpty) ...[
          _buildSkillSection(
            'Must Have Skills',
            _mustHave,
            const Color(0xFFD85A30),
          ),
          SizedBox(height: 24.h),
        ],
        if (_goodToHave.isNotEmpty) ...[
          _buildSkillSection(
            'Good to Have',
            _goodToHave,
            const Color(0xFF1D9E75),
          ),
        ],
        if (_mustHave.isEmpty && _goodToHave.isEmpty)
          Center(
            child: Text(
              'Roadmap skills are coming soon!',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildReadinessCard() {
    String careerLabel = CareerService.getCareerLabel(
      _careerData['career_goal'] ?? '',
    );

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(24.w),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    careerLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3730A3),
                    ),
                  ),
                  Text(
                    'Job Readiness Score',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_readiness.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4338CA),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.w),
            child: LinearProgressIndicator(
              value: _readiness / 100,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillSection(
    String title,
    List<Map<String, dynamic>> skills,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        SizedBox(height: 12.h),
        ...skills.map((skill) => _buildSkillRow(skill, color)),
      ],
    );
  }

  Widget _buildSkillRow(Map<String, dynamic> skill, Color themeColor) {
    final progressList = skill['user_skill_progress'];
    bool isCompleted = false;
    int progressPercent = 0;

    if (progressList != null && (progressList as List).isNotEmpty) {
      isCompleted = progressList[0]['is_completed'] ?? false;
      progressPercent = progressList[0]['progress_percent'] ?? 0;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  int newProgress = isCompleted ? 0 : 100;
                  await CareerService.updateSkillProgress(
                    skillId: skill['id'].toString(),
                    progressPercent: newProgress,
                    isCompleted: !isCompleted,
                  );
                  _loadCareerData();
                },
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? themeColor : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? themeColor : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill['skill_name'] ?? 'Skill',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.grey : const Color(0xFF4F200D),
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (skill['description'] != null)
                      Text(
                        skill['description'],
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '$progressPercent%',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.grey : themeColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(left: 36.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                minHeight: 4,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation(isCompleted ? themeColor : const Color(0xFFFF9A00)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCareerGoal() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No career goal set',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4F200D),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Set your career goal in profile settings to unlock your roadmap',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              content: 'Set Career Goal',
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              size: 'small',
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String content;
  final VoidCallback onPressed;
  final String size;

  const CustomButton({
    super.key,
    required this.content,
    required this.onPressed,
    this.size = 'medium',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9A00),
        foregroundColor: const Color(0xFF4F200D),
        padding: EdgeInsets.symmetric(
          horizontal: size == 'small' ? 16.w : 24.w,
          vertical: size == 'small' ? 8.h : 12.h,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      ),
      child: Text(
        content,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: size == 'small' ? 12.sp : 14.sp,
        ),
      ),
    );
  }
}
