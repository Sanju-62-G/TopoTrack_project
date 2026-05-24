import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';

class CareerSimulatorScreen extends StatefulWidget {
  const CareerSimulatorScreen({super.key});

  @override
  State<CareerSimulatorScreen> createState() => _CareerSimulatorScreenState();
}

class _CareerSimulatorScreenState extends State<CareerSimulatorScreen> {
  @override
  Widget build(BuildContext context) {
    Responsive().init(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F1E9),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: CareerStatWidget(
                            label: 'Career goal',
                            value: 'Flutter Dev',
                            subtext: 'Selected goal',
                            isHighlighted: false,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        const Expanded(
                          child: CareerStatWidget(
                            label: 'Skills done',
                            value: '4 / 12',
                            subtext: 'Core skills',
                            isHighlighted: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildSkillProgressSection(),
                    SizedBox(height: 24.h),
                    _buildSkillRoadmapSection(),
                    SizedBox(height: 24.h),
                    _buildCourseEffortSection(),
                    SizedBox(height: 32.h),
                    CustomButton(
                      content: 'Update Simulation',
                      width: double.infinity,
                      onPressed: () {},
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      content: 'Save Plan',
                      width: double.infinity,
                      variant: 'outline',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E9),
        border: Border(bottom: BorderSide(color: Color(0xFFFF9A00), width: 1)),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 24.h, 16.w, 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF4F200D), size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Career Simulator',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
            ),
          ),
          IconButton(
            icon: Icon(Icons.history_rounded, color: const Color(0xFF491706), size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSkillProgressSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAREER SKILL PROGRESS',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 20.h),
          _buildSkillProgressBar('Flutter & Dart', 0.65, '65%'),
          SizedBox(height: 16.h),
          _buildSkillProgressBar('OOP & Design', 0.40, '40%'),
          SizedBox(height: 16.h),
          _buildSkillProgressBar('REST APIs', 0.20, '20%'),
        ],
      ),
    );
  }

  Widget _buildSkillProgressBar(String label, double progress, String percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F200D))),
            Text(percentage, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(
                0xFFFF9A00))),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFF9A00)),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillRoadmapSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SKILL ROADMAP',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),
          _buildRoadmapItem(Icons.check_rounded, 'Dart basics', 'Completed', 'Done', const Color(0xFFE0E7FF), const Color(0xFF059669)),
          _buildRoadmapItem(Icons.play_arrow_rounded, 'Flutter widgets', 'In progress', '65%', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
          _buildRoadmapItem(Icons.lock_outline_rounded, 'State management', 'Locked', 'Next', const Color(0xFFF1F5F9), const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildRoadmapItem(IconData icon, String title, String status, String trailing, Color iconBg, Color statusColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12.w)),
            child: Icon(icon, color: statusColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F200D))),
                Text(status, style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Text(trailing, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }

  Widget _buildCourseEffortSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COURSE EFFORT (CAREER MODE)',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),
          _buildCourseEffortItem('Mobile App Dev', 'Career-relevant', 'High', const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
          _buildCourseEffortItem('Algorithms', 'General', 'Medium', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
          _buildCourseEffortItem('Technical Writing', 'General', 'Low', const Color(0xFFDCFCE7), const Color(0xFF166534)),
        ],
      ),
    );
  }

  Widget _buildCourseEffortItem(String title, String subtitle, String effort, Color effortBg, Color effortColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F200D))),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF64748B))),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(color: effortBg, borderRadius: BorderRadius.circular(8.w)),
            child: Text(
              effort,
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: effortColor),
            ),
          ),
        ],
      ),
    );
  }
}

class CareerStatWidget extends StatelessWidget {
  final String label, value, subtext;
  final bool isHighlighted;

  const CareerStatWidget({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFFF9A00) : Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: isHighlighted ? Colors.white70 : const Color(0xFF64748B))),
          SizedBox(height: 4.h),
          Text(value, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isHighlighted ? Colors.white : const Color(0xFF4F200D))),
          SizedBox(height: 4.h),
          Text(subtext, style: GoogleFonts.poppins(fontSize: 9.sp, color: isHighlighted ? Colors.white70 : const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
