import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Components/custom_button.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Study Progress'),
            const SizedBox(height: 16),
            _buildChartPlaceholder('Study Hours Graph', height: 180),
            const SizedBox(height: 32),
            _buildSectionTitle('GPA Trend'),
            const SizedBox(height: 16),
            _buildChartPlaceholder('GPA Trend Line', height: 150),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Completion'),
                      const SizedBox(height: 16),
                      _buildChartPlaceholder('Pie Chart', height: 150),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      CustomButton(
                        content: 'Weekly Report',
                        width: double.infinity,
                        variant: 'secondary',
                        onPressed: () {},
                        size: 'small',
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        content: 'Monthly Report',
                        width: double.infinity,
                        variant: 'secondary',
                        onPressed: () {},
                        size: 'small',
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        content: 'Export Report',
                        width: double.infinity,
                        onPressed: () {},
                        size: 'small',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildChartPlaceholder(String label, {required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: const Color(0xFFF6F1E9).withAlpha(51), size: 48),
            Text(
              label,
              style: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
