import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const _forgotIllustrationPath = 'assets/images/auth/forgot_password.jpg';
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              left: -88,
              top: -15,
              child: _DecorCircle(size: 220, color: Color(0xFFBDE9B7)),
            ),
            const Positioned(
              left: 30,
              top: -58,
              child: _DecorCircle(size: 185, color: Color(0xFFBDE9B7)),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 116, 24, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Quên mật khẩu ?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nhập email của bạn. Chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          _forgotIllustrationPath,
                          width: 300,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Image.asset(
                              'assets/images/auth/forgot_password.jpg',
                              width: 300,
                              height: 250,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_emailSent) ...[
                      _AuthInput(
                        controller: _emailController,
                        hintText: 'Nhập email của bạn',
                        keyboardType: TextInputType.emailAddress,
                        validator: _requiredEmail,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  await auth.resetPassword(
                                    _emailController.text.trim(),
                                  );
                                  if (!mounted) return;
                                  if (auth.error == null) {
                                    setState(() => _emailSent = true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Email đặt lại mật khẩu đã được gửi!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    _showErrorIfAny(context, auth.error);
                                  }
                                },
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Gửi liên kết',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Color(0xFF2ECC71),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đã gửi liên kết đặt lại mật khẩu tới ${_emailController.text.trim()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () async {
                            await auth.resetPassword(_emailController.text.trim());
                            if (!mounted) return;
                            if (auth.error == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email đã được gửi lại!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              _showErrorIfAny(context, auth.error);
                            }
                          },
                          child: const Text(
                            'Gửi lại email',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () => context.navigateToLogin(),
                      child: const Text(
                        'Quay lại Đăng nhập',
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (auth.error != null && !_emailSent) ...[
                      const SizedBox(height: 8),
                      Text(
                        auth.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
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
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF767A77),
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0x5CD0E7CF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
        ),
      ),
    );
  }
}

String? _requiredEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email không được để trống';
  }
  if (!value.contains('@')) {
    return 'Email không hợp lệ';
  }
  return null;
}

void _showErrorIfAny(BuildContext context, String? error) {
  if (error == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
}

