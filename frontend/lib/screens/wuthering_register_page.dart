import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'wuthering_login_page.dart';

class WutheringRegisterPage extends StatefulWidget {
  const WutheringRegisterPage({super.key});

  @override
  State<WutheringRegisterPage> createState() => _WutheringRegisterPageState();
}

class _WutheringRegisterPageState extends State<WutheringRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── VALIDATORS ────────────────────────────────────────────────────────────
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name cannot be empty.';
    if (v.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await Provider.of<AuthProvider>(context, listen: false)
        .register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      showDialog(
        context: context,
        builder: (ctx) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: AlertDialog(
            backgroundColor: const Color(0xFF001A00),
            shape: const BeveledRectangleBorder(
              side: BorderSide(color: Colors.greenAccent, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                const SizedBox(width: 10),
                Text(
                  'ACCESS GRANTED',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    color: Colors.greenAccent,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Identity registered successfully. You can now login.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const WutheringLoginPage()),
                  );
                },
                child: Text(
                  'PROCEED TO LOGIN',
                  style: GoogleFonts.orbitron(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2D0000),
          content: Text(
            '✗ ${result['message']}',
            style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 11),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.redAccent, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: GridPaper(
                color: AppTheme.accentColor,
                interval: 40,
                divisions: 1,
                subdivisions: 1,
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white38, size: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.accentColor.withOpacity(0.25),
                              width: 1.5),
                          color: AppTheme.accentColor.withOpacity(0.06),
                        ),
                        child: const Icon(Icons.person_add_outlined,
                            size: 38, color: AppTheme.accentColor),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        color: AppTheme.accentColor.withOpacity(0.8),
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Glassmorphic Form Card ──────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1.2),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        width: 3,
                                        height: 12,
                                        color: AppTheme.accentColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'REGISTER PROTOCOL',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Name field
                                TextFormField(
                                  controller: _nameController,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                  validator: _validateName,
                                  decoration: _deco('RESONATOR NAME',
                                      Icons.person_outline),
                                ),
                                const SizedBox(height: 16),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _deco(
                                      'RESONATOR EMAIL', Icons.alternate_email),
                                ),
                                const SizedBox(height: 16),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                  validator: _validatePassword,
                                  obscureText: _obscureText,
                                  decoration: _deco(
                                    'ACCESS KEY (min 6 chars)',
                                    Icons.vpn_key_outlined,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white38,
                                        size: 16,
                                      ),
                                      onPressed: () => setState(
                                          () => _obscureText = !_obscureText),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Submit
                                GestureDetector(
                                  onTap: _isLoading ? null : _register,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: _isLoading
                                          ? null
                                          : const LinearGradient(
                                              colors: [
                                                AppTheme.accentColor,
                                                Color(0xFF00A89C),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      color: _isLoading
                                          ? AppTheme.borderColor
                                          : null,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: _isLoading
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: AppTheme.accentColor
                                                    .withOpacity(0.3),
                                                blurRadius: 14,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                        Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'REGISTER',
                                              style: GoogleFonts.orbitron(
                                                color: AppTheme.darkBg,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12.5,
                                                letterSpacing: 1.5,
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
                    ),
                    const SizedBox(height: 28),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const WutheringLoginPage()),
                          ),
                          child: Text(
                            'Login here',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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

  InputDecoration _deco(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.orbitron(
        fontSize: 9.5,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 1,
      ),
      prefixIcon:
          Icon(icon, color: Colors.white.withOpacity(0.35), size: 16),
      suffixIcon: suffixIcon,
      fillColor: Colors.black.withOpacity(0.35),
      errorStyle: GoogleFonts.orbitron(
        fontSize: 9.5,
        color: Colors.redAccent,
      ),
    );
  }
}
