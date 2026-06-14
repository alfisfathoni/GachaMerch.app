import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'wuthering_login_page.dart';
import 'wuthering_admin_dashboard.dart';
import 'wuthering_user_dashboard.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuth() async {
    await Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Widget destination;
      if (!auth.isAuthenticated) {
        destination = const WutheringLoginPage();
      } else if (auth.role == 'admin') {
        destination = const WutheringAdminDashboard();
      } else {
        destination = const WutheringUserDashboard();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Cyber grid lines representation
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: GridPaper(
                  color: AppTheme.accentColor,
                  interval: 30,
                  divisions: 1,
                  subdivisions: 1,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size(160, 160),
                    painter: WuWaLogoPainter(),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'GACHAMERCH',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RESONANCE TERMINAL ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor.withOpacity(0.6)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WuWaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Cyan ring
    final paintCyan = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 40, paintCyan);
    
    // Outer dashed ring indicator
    final paintDotted = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 55, paintDotted);

    // Crosshairs
    final paintLine = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(center.dx - 65, center.dy), Offset(center.dx - 50, center.dy), paintLine);
    canvas.drawLine(Offset(center.dx + 50, center.dy), Offset(center.dx + 65, center.dy), paintLine);
    canvas.drawLine(Offset(center.dx, center.dy - 65), Offset(center.dx, center.dy - 50), paintLine);
    canvas.drawLine(Offset(center.dx, center.dy + 50), Offset(center.dx, center.dy + 65), paintLine);

    // Diamond core
    final path = Path();
    path.moveTo(center.dx, center.dy - 18);
    path.lineTo(center.dx + 13, center.dy);
    path.lineTo(center.dx, center.dy + 18);
    path.lineTo(center.dx - 13, center.dy);
    path.close();
    
    final paintGold = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintGold);
    
    // Cyan inner point
    final paintInner = Paint()..color = AppTheme.darkBg;
    canvas.drawCircle(center, 4, paintInner);
    final paintInnerCyan = Paint()..color = AppTheme.accentColor;
    canvas.drawCircle(center, 2, paintInnerCyan);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
