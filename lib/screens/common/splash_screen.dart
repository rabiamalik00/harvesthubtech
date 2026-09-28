import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/routes.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

/// Splash Screen – shown on every cold start (SRS requirement).
/// Displays HarvestHub logo + tagline for ~2.6s, then routes
/// to Login (unauthenticated) or role dashboard (authenticated).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    Timer(const Duration(milliseconds: 2600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.isAuthenticated && auth.currentUser != null) {
      AppRoutes.navigateToRoleDashboard(context, auth.currentUser!.role);
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (ctx, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: const LoginScreen(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -size.height * 0.08,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.15,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Central content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated logo badge
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) => Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.04),
                    child: child,
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        size: 58,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 22),

                const Text(
                  'HarvestHub',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.0,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 8),

                const Text(
                  'Farm Fresh · Direct to You',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                const SizedBox(height: 48),

                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 800.ms),
              ],
            ),
          ),

          // Bottom brand stamp
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Powered by HarvestHub Platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
          ),
        ],
      ),
    );
  }
}
