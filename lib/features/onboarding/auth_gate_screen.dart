import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../mansion_store.dart';
import '../../sound_service.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key, required this.store});

  final MansionStore store;

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  static const Color _voidBg = Color(0xFF0B0B0D);
  static const Color _coalSurface = Color(0xFF17171A);
  static const Color _gothBorder = Color(0xFF3B3329);
  static const Color _boneText = Color(0xFFE9E0D0);
  static const Color _mutedStone = Color(0xFFA79C8C);
  static const Color _goldAccent = Color(0xFFC6A15B);
  static const Color _bloodWine = Color(0xFF6E1830);
  static const Color _bloodBorder = Color(0xFF9B3B48);

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isSubmittingGoogle = false;
  String? _errorText;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitCredentials() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final ok = _isRegisterMode
        ? await widget.store.registerWithEmailAsync(
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await widget.store.signInWithEmailAsync(
            email: _emailController.text,
            password: _passwordController.text,
          );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _isSubmitting = false;
        _errorText = widget.store.lastSyncError ?? 'Ověření se nezdařilo.';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSubmitting = true;
      _isSubmittingGoogle = true;
      _errorText = null;
    });
    final ok = await widget.store.signInWithGoogleAsync();
    if (!mounted) return;
    if (!ok) {
      final msg =
          widget.store.lastSyncError ?? 'Přihlášení přes Google selhalo.';
      setState(() {
        _isSubmitting = false;
        _isSubmittingGoogle = false;
        _errorText = msg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: _voidBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/branding/splash_mark.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      s.authEyebrow,
                      style: const TextStyle(
                        color: _goldAccent,
                        fontSize: 11,
                        letterSpacing: 2.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'GrimGrind',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _boneText,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Přihlas se do svého rodu nebo založ nový účet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _mutedStone, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _coalSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gothBorder, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Přihlásit se'),
                            icon: Icon(Icons.login, size: 16),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Registrace'),
                            icon: Icon(Icons.person_add_alt_1, size: 16),
                          ),
                        ],
                        selected: {_isRegisterMode},
                        onSelectionChanged: _isSubmitting
                            ? null
                            : (s) => setState(() {
                                _isRegisterMode = s.first;
                                _errorText = null;
                              }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: _voidBg,
                          labelText: 'E-mail',
                          prefixIcon: Icon(
                            Icons.alternate_email,
                            color: _mutedStone,
                            size: 18,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _voidBg,
                          labelText: 'Heslo',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: _mutedStone,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _mutedStone,
                              size: 18,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _bloodWine.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _bloodBorder),
                          ),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              color: _bloodBorder,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _bloodWine,
                          foregroundColor: _boneText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: _bloodBorder),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : withButtonSound(_submitCredentials),
                        icon: const Icon(Icons.key_outlined, size: 18),
                        label: Text(
                          _isSubmitting
                              ? s.authVerifyingSeal
                              : (_isRegisterMode
                                    ? s.authCreateAccountBtn
                                    : s.authSignInBtn),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: _gothBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              s.authOr,
                              style: const TextStyle(
                                color: _mutedStone,
                                fontSize: 11,
                                letterSpacing: 1.6,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: _gothBorder)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _voidBg,
                          foregroundColor: _boneText,
                          side: const BorderSide(color: _goldAccent),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : withButtonSound(_signInWithGoogle),
                        icon: _isSubmittingGoogle
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _goldAccent,
                                ),
                              )
                            : const Icon(
                                Icons.g_mobiledata,
                                color: _goldAccent,
                                size: 24,
                              ),
                        label: Text(
                          _isSubmittingGoogle
                              ? s.authVerifyingSeal
                              : s.authContinueGoogle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '„Kdo překročí práh bez pečetě, stane se pouhým stínem v kronice.“',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _mutedStone,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
