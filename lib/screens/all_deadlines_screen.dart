import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../services/deadline_service.dart';
import '../Components/deadline_item.dart';
import 'add_deadline_screen.dart';
import 'edit_deadline_screen.dart';

class AllDeadlinesScreen extends StatefulWidget {
  const AllDeadlinesScreen({super.key});

  @override
  State<AllDeadlinesScreen> createState() => _AllDeadlinesScreenState();
}

class _AllDeadlinesScreenState extends State<AllDeadlinesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _deadlines = [];

  @override
  void initState() {
    super.initState();
    _fetchDeadlines();
  }

  Future<void> _fetchDeadlines() async {
    try {
      final deadlines = await DeadlineService.getDeadlines();
      setState(() {
        _deadlines = deadlines;
      });
    } catch (e) {
      debugPrint('Error fetching deadlines: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDeadlineTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    String dateStr;
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      dateStr = 'Today';
    } else if (dateTime.year == tomorrow.year && dateTime.month == tomorrow.month && dateTime.day == tomorrow.day) {
      dateStr = 'Tomorrow';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateStr = '${months[dateTime.month - 1]} ${dateTime.day}';
    }

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$dateStr, $hour:$minute $amPm';
  }

  Future<T?> _showSidePanel<T>(Widget screen) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Side Panel',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.9,
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F1E9),
                borderRadius: BorderRadius.circular(24.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.w),
                child: screen,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF4F200D), size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Deadlines',
          style: GoogleFonts.interTight(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
          : _deadlines.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.all(24.w),
                  itemCount: _deadlines.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final deadline = _deadlines[index];
                    final deadlineTime = DateTime.parse(deadline['deadline_at']);
                    final diff = deadlineTime.difference(DateTime.now()).inDays;
                    
                    Color accentColor = const Color(0xFF22C55E); // Green
                    if (diff <= 1) {
                      accentColor = const Color(0xFFEF4444); // Red
                    } else if (diff <= 3) {
                      accentColor = const Color(0xFFF59E0B); // Amber
                    }

                    return DeadlineItem(
                      accentColor: accentColor,
                      course: deadline['course_code'] ?? 'N/A',
                      time: _formatDeadlineTime(deadline['deadline_at']),
                      title: deadline['title'] ?? 'Untitled',
                      onEdit: () async {
                        final result = await _showSidePanel(
                          EditDeadlineScreen(deadline: deadline),
                        );
                        if (result == true) {
                          _fetchDeadlines();
                        }
                      },
                      onDelete: () async {
                        final bool confirm = await _showDeleteDialog(deadline['title']);
                        if (confirm) {
                          await DeadlineService.deleteDeadline(deadline['id']);
                          _fetchDeadlines();
                        }
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showSidePanel(const AddDeadlineScreen());
          _fetchDeadlines(); // Refresh after adding
        },
        backgroundColor: const Color(0xFFFF9A00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<bool> _showDeleteDialog(String? title) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6F1E9),
        title: Text('Remove Deadline', style: GoogleFonts.interTight(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_outlined, size: 64.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'No deadlines yet!',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first deadline to stay on track.',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
