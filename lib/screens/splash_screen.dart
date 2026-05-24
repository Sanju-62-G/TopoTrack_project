import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Components/custom_button.dart';
import '../utils/responsive.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Small delay for branding
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    if (AuthService.instance.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // If not authenticated, we stay on this screen to show "Get Started" 
      // or we could automatically go to onboarding. 
      // For now, staying to show the branding is fine, 
      // but let's make sure the state is updated.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    final bool isAuth = AuthService.instance.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Placeholder
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9A00),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withAlpha(40),
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  )
                ],
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Icon(
                Icons.hub_rounded,
                color: const Color(0xFFFFF8E8),
                size: 48.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'TopoTrack',
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4F200D),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Visual Study Planner and Career Roadmap',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: const Color(0xFF4F200D),
              ),
            ),
            SizedBox(height: 48.h),
            isAuth
              ? const CircularProgressIndicator(color: Color(0xFFFF9A00))
              : CustomButton(
                  content: 'Get Started',
                  size: 'medium',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/onboarding');
                  },
                ),
          ],
        ),
      ),
    );
  }
}
