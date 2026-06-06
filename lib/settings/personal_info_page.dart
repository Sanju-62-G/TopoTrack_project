import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../services/auth_service.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _deptController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (profile != null) {
        setState(() {
          _nameController.text = profile['full_name'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _idController.text = profile['student_id'] ?? '';
          _deptController.text = profile['department'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.updateProfile(
        fullName: _nameController.text.trim(),
        studentId: _idController.text.trim(),
        department: _deptController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: _buildAppBar(context),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Profile Picture'),
                  SizedBox(height: 16.h),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF9A00), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/300'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4F200D),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Account Details'),
                  SizedBox(height: 16.h),
                  _buildInputField('Full Name', _nameController),
                  _buildInputField('Email Address', _emailController, enabled: false),
                  _buildInputField('Student ID', _idController),
                  _buildInputField('Department', _deptController),
                  SizedBox(height: 32.h),
                  CustomButton(
                    content: 'Save Changes',
                    width: double.infinity,
                    onPressed: _saveChanges,
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
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF4F200D), size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Personal Information',
        style: GoogleFonts.interTight(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F200D),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.interTight(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4F200D).withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool enabled = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            enabled: enabled,
            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F200D)),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade200,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(color: const Color(0xFFFF9A00)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
