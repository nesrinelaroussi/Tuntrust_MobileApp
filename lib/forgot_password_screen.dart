import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _userId;
  String? _errorMessage;
  String? _successMessage;

  static const Color _green = Color(0xFF05B257);
  static const Color _teal = Color(0xFF007A87);

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final result = await ApiService.forgotPassword(
        email: _emailController.text.trim(),
      );
      setState(() {
        _userId = result['userId'] as String?;
        _otpSent = true;
        _successMessage = 'Code envoyé à ${_emailController.text.trim()}. Vérifiez votre boîte mail ou la console du serveur.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtpAndReset() async {
    if (_otpController.text.length < 4) {
      setState(() => _errorMessage = 'Entrez le code à 4 chiffres.');
      return;
    }
    if (_newPasswordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      setState(() => _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ApiService.resetPassword(
        userId: _userId!,
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text,
      );
      if (mounted) {
        setState(() {
          _successMessage = 'Mot de passe modifié avec succès ! Redirection...';
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Curved gradient header ─────────────────────────
            Container(
              width: double.infinity,
              height: size.height * 0.28,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_green, _teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_reset, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mot de passe oublié',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _otpSent ? 'Entrez le code reçu par e-mail' : 'Nous vous enverrons un code de vérification',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Step indicator ──────────────────────────
                    Row(
                      children: [
                        _stepDot(1, true),
                        Expanded(child: Container(height: 2, color: _otpSent ? _green : Colors.grey.shade200)),
                        _stepDot(2, _otpSent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Email', style: TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w600)),
                        Text('Nouveau mot de passe', style: TextStyle(fontSize: 11, color: _otpSent ? _green : Colors.grey.shade400, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Messages ────────────────────────────────
                    if (_errorMessage != null) _messageBanner(_errorMessage!, isError: true),
                    if (_successMessage != null) _messageBanner(_successMessage!, isError: false),

                    // ── Step 1: Email ───────────────────────────
                    if (!_otpSent) ...[
                      _buildTextField(
                        controller: _emailController,
                        label: 'Adresse e-mail',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Entrez votre e-mail';
                          if (!v.contains('@')) return 'E-mail invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      _actionButton(
                        label: 'Envoyer le code',
                        onPressed: _isLoading ? null : _sendOtp,
                        isLoading: _isLoading,
                      ),
                    ],

                    // ── Step 2: OTP + New Password ──────────────
                    if (_otpSent) ...[
                      _buildTextField(
                        controller: _otpController,
                        label: 'Code à 4 chiffres',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _newPasswordController,
                        label: 'Nouveau mot de passe',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmController,
                        label: 'Confirmer le mot de passe',
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirm,
                        enabled: !_isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _actionButton(
                        label: 'Réinitialiser le mot de passe',
                        onPressed: _isLoading ? null : _verifyOtpAndReset,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 16, color: _green),
                          label: const Text('Renvoyer le code', style: TextStyle(color: _green, fontSize: 13)),
                          onPressed: _isLoading ? null : () => setState(() {
                            _otpSent = false;
                            _errorMessage = null;
                            _successMessage = null;
                          }),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(int step, bool active) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? _green : Colors.grey.shade200,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(color: active ? Colors.white : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _messageBanner(String message, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isError ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red.shade400 : Colors.green.shade600,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red.shade700 : Colors.green.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF6F8FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: _green, width: 1.8)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade300)),
      ),
    );
  }

  Widget _actionButton({required String label, required VoidCallback? onPressed, required bool isLoading}) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _green.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
