import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'wuthering_register_page.dart';
import 'wuthering_admin_dashboard.dart';
import 'wuthering_user_dashboard.dart';

class WutheringLoginPage extends StatefulWidget {
  const WutheringLoginPage({super.key});

  @override
  State<WutheringLoginPage> createState() => _WutheringLoginPageState();
}

class _WutheringLoginPageState extends State<WutheringLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('CONNECTION DENIED', 'Please input both Resonator Email and Access Key.');
      return;
    }

    if (!email.contains('@')) {
      _showErrorDialog('FORMAT INVALID', 'Email format is incorrect. Please verify.');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.login(email, password);

    setState(() => _isLoading = false);

    if (response != null) {
      if (!mounted) return;
      
      if (response['role'].toString().toLowerCase() == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WutheringAdminDashboard()),
        );
      } else if (response['role'].toString().toLowerCase() == 'user') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WutheringUserDashboard()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WutheringUserDashboard()),
        );
      }
    } else {
      _showErrorDialog('ACCESS RESTRICTED', 'Invalid credentials. Please verify your clearance.');
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isGoogleLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cardColor.withOpacity(0.9),
        content: Row(
          children: [
            const Icon(Icons.g_mobiledata, color: AppTheme.accentColor, size: 32),
            const SizedBox(width: 8),
            Text(
              'OAuth Integration Active: Select account in browser.',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppTheme.accentColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.85),
          shape: const BeveledRectangleBorder(
            side: BorderSide(color: Colors.redAccent, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          title: Row(
            children: [
              const Icon(Icons.gpp_bad_outlined, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          content: Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'DISMISS',
                style: GoogleFonts.orbitron(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Cybertech background lines
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: GridPaper(
                color: AppTheme.primaryColor,
                interval: 40,
                divisions: 1,
                subdivisions: 1,
              ),
            ),
          ),
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Logo / Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25), width: 1.5),
                          color: AppTheme.darkBg.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.radar,
                          size: 44,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'WUTHERING WAVES STORE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'GACHA MERCH',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        color: AppTheme.accentColor.withOpacity(0.9),
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 14,
                                    color: AppTheme.accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AUTHENTICATION REQUIRED',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.6),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Email Field
                              TextField(
                                controller: _emailController,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'RESONATOR EMAIL',
                                  labelStyle: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.4),
                                    letterSpacing: 1,
                                  ),
                                  prefixIcon: Icon(Icons.alternate_email, color: Colors.white.withOpacity(0.35), size: 16),
                                  fillColor: Colors.black.withOpacity(0.35),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              TextField(
                                controller: _passwordController,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  labelText: 'ACCESS KEY',
                                  labelStyle: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.4),
                                    letterSpacing: 1,
                                  ),
                                  prefixIcon: Icon(Icons.vpn_key_outlined, color: Colors.white.withOpacity(0.35), size: 16),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.white.withOpacity(0.35),
                                      size: 16,
                                    ),
                                    onPressed: () => setState(() => _obscureText = !_obscureText),
                                  ),
                                  fillColor: Colors.black.withOpacity(0.35),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Action Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                  ),
                                ).copyWith(
                                  elevation: WidgetStateProperty.all(0),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor,
                                        Color(0xFFE8C26E),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    constraints: const BoxConstraints(minHeight: 52),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBg),
                                            ),
                                          )
                                        : Text(
                                            'LOGIN',
                                            style: GoogleFonts.orbitron(
                                              color: AppTheme.darkBg,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up / Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const WutheringRegisterPage()),
                            );
                          },
                          child: Text(
                            'Register here',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google OAuth Button
                    Center(
                      child: Text(
                        'OR CONNECT THROUGH',
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.35),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                      icon: _isGoogleLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                              height: 16,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata, color: Colors.white, size: 16);
                              },
                            ),
                      label: Text(
                        'SIGN IN WITH GOOGLE',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.white.withOpacity(0.85),
                        side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.2),
                        backgroundColor: Colors.white.withOpacity(0.01),
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Footer
                    Text(
                      'SOL-3 ENCRYPTION SECURED • V0.9.0',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        color: Colors.grey[600],
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
