import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Components/custom_button.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dependency Graph',
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
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNode('Data Structure', isCompleted: true),
                  const Icon(Icons.arrow_downward, color: Color(0xFF94A3B8)),
                  _buildNode('Graph', isCompleted: true),
                  const Icon(Icons.arrow_downward, color: Color(0xFF94A3B8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNode('DAG'),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      _buildNode('Topo Sort'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    content: 'Generate Order',
                    iconPresent: true,
                    icon: const Icon(Icons.auto_fix_high, size: 16, color: Color(0xFF4F200D)),
                    onPressed: () {},
                    size: 'small',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    content: 'View Full Graph',
                    iconPresent: true,
                    icon: const Icon(Icons.fullscreen, size: 16, color: Color(0xFF1E293B)),
                    onPressed: () {},
                    variant: 'secondary',
                    size: 'small',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    content: 'Add Dependency',
                    iconPresent: true,
                    icon: const Icon(Icons.add_link, size: 16, color: Color(0xFF1E293B)),
                    onPressed: () {},
                    variant: 'secondary',
                    size: 'small',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    content: 'Remove',
                    iconPresent: true,
                    icon: const Icon(Icons.link_off, size: 16, color: Colors.white),
                    onPressed: () {},
                    variant: 'destructive',
                    size: 'small',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Recommended Study Order',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withAlpha(12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4F46E5).withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderItem('1. Graph Basics'),
                  _buildOrderItem('2. DAG'),
                  _buildOrderItem('3. Topological Sort'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(String text, {bool isCompleted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF10B981) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? Colors.transparent : const Color(0xFF4F46E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isCompleted ? Colors.white : const Color(0xFF4F46E5),
        ),
      ),
    );
  }

  Widget _buildOrderItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF4F46E5)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
