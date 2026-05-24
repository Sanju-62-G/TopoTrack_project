import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';

class HybridSimulatorScreen extends StatefulWidget {
  const HybridSimulatorScreen({super.key});

  @override
  State<HybridSimulatorScreen> createState() => _HybridSimulatorScreenState();
}

class _HybridSimulatorScreenState extends State<HybridSimulatorScreen> {
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
                    _buildSummaryCards(),
                    SizedBox(height: 24.h),
                    _buildDualProgressTracker(),
                    SizedBox(height: 24.h),
                    _buildBalancedCoursePriorities(),
                    SizedBox(height: 24.h),
                    _buildInsightCard(),
                    SizedBox(height: 32.h),
                    CustomButton(
                      content: 'Optimize Schedule',
                      width: double.infinity,
                      onPressed: () {},
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      content: 'Save Strategy',
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
            'Hybrid Simulator',
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        const Expanded(
          child: SummaryStatWidget(
            label: 'Current CGPA',
            value: '3.62',
            subtext: 'Target: 3.85',
          ),
        ),
        SizedBox(width: 16.w),
        const Expanded(
          child: SummaryStatWidget(
            label: 'Career skills',
            value: '33%',
            subtext: '4 of 12 done',
          ),
        ),
      ],
    );
  }

  Widget _buildDualProgressTracker() {
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
            'DUAL PROGRESS TRACKER',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 20.h),
          _buildProgressRow('CGPA goal', 0.72, '72%', const Color(0xFF059669)),
          SizedBox(height: 16.h),
          _buildProgressRow('Career skills', 0.33, '33%', const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double progress, String percentage, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F200D))),
            Text(percentage, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBalancedCoursePriorities() {
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
            'BALANCED COURSE PRIORITIES',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),
          _buildPriorityItem('Mobile App Dev', '3 cr · Career-relevant', 'High', const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
          _buildPriorityItem('Algorithms', '3 cr · CGPA critical', 'High', const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
          _buildPriorityItem('OS', '2 cr · General', 'Medium', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
          _buildPriorityItem('Technical Writing', '1.5 cr · General', 'Low', const Color(0xFFDCFCE7), const Color(0xFF166534)),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(String title, String subtitle, String priority, Color priorityBg, Color priorityColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F200D))),
                    Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(8.w)),
                child: Text(
                  priority,
                  style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: priorityColor),
                ),
              ),
            ],
          ),
          if (title != 'Technical Writing') ...[
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ]
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: const Color(0xFF4338CA), size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Focus on Mobile App Dev this week — it boosts both your CGPA and Flutter career skills at the same time.',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: const Color(0xFF3730A3),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryStatWidget extends StatelessWidget {
  final String label, value, subtext;

  const SummaryStatWidget({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtext,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
