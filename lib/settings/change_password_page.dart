import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../services/supabase_client.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SupabaseClientService.auth.updateUser(
        UserAttributes(password: newPass),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a strong password to protect your academic data.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF4F200D).withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 32.h),
            _buildPasswordField(
              'New Password',
              'Enter new password',
              _newPasswordController,
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
            ),
            SizedBox(height: 16.h),
            _buildPasswordField(
              'Confirm New Password',
              'Repeat new password',
              _confirmPasswordController,
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            SizedBox(height: 40.h),
            _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
                : CustomButton(
                    content: 'Update Password',
                    width: double.infinity,
                    onPressed: _updatePassword,
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
        'Change Password',
        style: GoogleFonts.interTight(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F200D),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.interTight(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF4F200D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20.sp,
              ),
              onPressed: onToggle,
            ),
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
}
