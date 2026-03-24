import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _loginIllustrationPath = 'assets/images/auth/login.jpg';
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              left: -95,
              top: -10,
              child: _DecorCircle(size: 220, color: Color(0xFFBDE9B7)),
            ),
            const Positioned(
              left: 15,
              top: -60,
              child: _DecorCircle(size: 190, color: Color(0xFFBDE9B7)),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 116, 24, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Chào mừng bạn quay lại !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đăng nhập để tiếp tục hành trình ăn uống lành mạnh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          _loginIllustrationPath,
                          width: 260,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Image.asset(
                              'assets/images/auth/login.jpg',
                              width: 260,
                              height: 220,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _AuthInput(
                      controller: _emailController,
                      hintText: 'Nhập email của bạn',
                      keyboardType: TextInputType.emailAddress,
                      validator: _requiredEmail,
                    ),
                    const SizedBox(height: 14),
                    _AuthInput(
                      controller: _passwordController,
                      hintText: 'Nhập mật khẩu',
                      obscureText: _obscurePassword,
                      validator: _requiredPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.navigateToForgotPassword(),
                        child: const Text(
                          'Quên mật khẩu ?',
                          style: TextStyle(color: Color(0xFF2ECC71)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                                await auth.signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );
                                if (!mounted) return;
                                if (auth.error == null) {
                                  context.navigateToHome();
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
                                'Đăng nhập',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFDADCE0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          await auth.signInWithGoogle();
                          if (!mounted) return;
                          if (auth.error == null) {
                            context.navigateToHome();
                          } else {
                            _showErrorIfAny(context, auth.error);
                          }
                        },
                        icon: const Icon(
                          Icons.g_mobiledata_rounded,
                          color: Color(0xFF5F6368),
                          size: 28,
                        ),
                        label: const Text(
                          'Đăng nhập với Google',
                          style: TextStyle(
                            color: Color(0xFF202124),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Bạn chưa có tài khoản? '),
                        TextButton(
                          onPressed: () => context.navigateToSignUp(),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(color: Color(0xFF2ECC71)),
                          ),
                        ),
                      ],
                    ),
                    if (auth.error != null) ...[
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
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF767A77),
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: suffixIcon,
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

String? _requiredPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Mật khẩu không được để trống';
  }
  if (value.length < 6) {
    return 'Mật khẩu cần tối thiểu 6 ký tự';
  }
  return null;
}

void _showErrorIfAny(BuildContext context, String? error) {
  if (error == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
}
