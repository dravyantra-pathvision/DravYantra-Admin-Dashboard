// features/authentication/screens/admin_login_screen.dart
// Premium dark admin login screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }
    final auth    = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) context.go('/dashboard');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AdminTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address to reset your password.');
      return;
    }
    
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(email);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset link sent to your email.'),
            backgroundColor: AdminTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: Row(
        children: [
          // ── Left panel — branding ────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1117), Color(0xFF1A1F35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: AdminTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AdminTheme.primary.withOpacity(0.4), blurRadius: 30, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 36),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 28),

                  const Text(
                    'DravYantra',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary, letterSpacing: -1),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.3),

                  const SizedBox(height: 8),

                  const Text(
                    'Admin Control Panel',
                    style: TextStyle(fontSize: 16, color: AdminTheme.textSecondary, fontWeight: FontWeight.w500),
                  ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

                  const SizedBox(height: 48),

                  // Feature highlights
                  ...[
                    ('🚛', 'Fleet Management',    'Manage all vehicles and drivers'),
                    ('📊', 'Real-time Analytics', 'Platform-wide insights and reports'),
                    ('🔔', 'Alert Center',        'Monitor alerts across all organizations'),
                    ('⚙️',  'System Control',     'Platform subscriptions and settings'),
                  ].map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 48),
                    child: Row(
                      children: [
                        Text(f.$1, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.$2, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(f.$3, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: -0.2)),

                  const SizedBox(height: 64),
                  Text('Pathvision Innovations © ${DateTime.now().year}',
                    style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ),

          // ── Right panel — login form ──────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              color: AdminTheme.surface,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome back',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
                            const SizedBox(height: 8),
                            const Text('Sign in to your admin account',
                              style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14)),

                            const SizedBox(height: 40),

                            // Error banner
                            if (auth.state == AuthState.error && auth.error != null)
                              Container(
                                margin:  const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:        AdminTheme.danger.withOpacity(0.1),
                                  border:       Border.all(color: AdminTheme.danger.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline, color: AdminTheme.danger, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(auth.error!, style: const TextStyle(color: AdminTheme.danger, fontSize: 13))),
                                ]),
                              ).animate().shake(),

                            // Email field
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: AdminTheme.textPrimary),
                              decoration: const InputDecoration(
                                labelText:   'Email address',
                                hintText:    'admin@company.com',
                                prefixIcon:  Icon(Icons.email_outlined),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            TextField(
                              controller:   _passwordCtrl,
                              obscureText:  _obscure,
                              style: const TextStyle(color: AdminTheme.textPrimary),
                              onSubmitted:  (_) => _handleLogin(),
                              decoration: InputDecoration(
                                labelText:  'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  color: AdminTheme.textSecondary,
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                child: const Text('Forgot Password?', style: TextStyle(color: AdminTheme.primaryLight, fontSize: 13)),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: auth.state == AuthState.loading ? null : _handleLogin,
                                child: auth.state == AuthState.loading
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 18),
                                      ],
                                    ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color:        AdminTheme.card,
                                  borderRadius: BorderRadius.circular(8),
                                  border:       Border.all(color: AdminTheme.border),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield_outlined, size: 14, color: AdminTheme.textMuted),
                                    SizedBox(width: 6),
                                    Text('Admin access only', style: TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
