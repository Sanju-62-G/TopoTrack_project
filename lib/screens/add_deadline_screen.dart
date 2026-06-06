import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../services/deadline_service.dart';
import '../services/notification_service.dart';

class AddDeadlineScreen extends StatefulWidget {
  const AddDeadlineScreen({super.key});

  @override
  State<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('What\'s the deadline for?'),
            SizedBox(height: 16.h),
            _buildInputField(
              controller: _titleController,
              hint: 'e.g. Final Project Submission',
              label: 'Deadline Title',
            ),
            SizedBox(height: 24.h),
            _buildInputField(
              controller: _courseController,
              hint: 'e.g. CSE301',
              label: 'Course Code',
            ),
            SizedBox(height: 24.h),
            _buildInputField(
              controller: _topicController,
              hint: 'e.g. Dynamic Programming, study from page 20-50, focus on Knapsack problem...',
              label: 'Topic / Description (Optional)',
              maxLines: 3,
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('When is it due?'),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildPickerTile(
                    label: 'Date',
                    value: _selectedDate == null 
                        ? 'Select Date' 
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    icon: Icons.calendar_today_rounded,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildPickerTile(
                    label: 'Time (Optional)',
                    value: _selectedTime == null 
                        ? 'Select Time' 
                        : _selectedTime!.format(context),
                    icon: Icons.access_time_rounded,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            CustomButton(
              content: 'Add Deadline',
              width: double.infinity,
              onPressed: () async {
                if (_titleController.text.isNotEmpty && _selectedDate != null) {
                  final DateTime deadlineDateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime?.hour ?? 0,
                    _selectedTime?.minute ?? 0,
                  );

                  await DeadlineService.addDeadline(
                    title: _titleController.text,
                    courseCode: _courseController.text,
                    topic: _topicController.text,
                    deadlineAt: deadlineDateTime,
                  );

                  await NotificationService.scheduleDeadlineReminders(
                    title: _titleController.text,
                    deadlineAt: deadlineDateTime,
                    baseId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: const Color(0xFF4F200D), size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'New Deadline',
        style: GoogleFonts.interTight(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F200D),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.interTight(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4F200D),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF4F200D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFFF9A00)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: const Color(0xFFFF9A00)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp, 
                      color: value.contains('Select') ? Colors.grey.shade400 : const Color(0xFF4F200D)
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
