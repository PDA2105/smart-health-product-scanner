import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _requiredEmail,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  obscureText: true,
                  validator: _requiredPassword,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.navigateToForgotPassword(),
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: 'Đăng nhập',
                  isLoading: auth.isLoading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    await auth.signIn(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    if (!mounted) return;
                    _showErrorIfAny(context, auth.error);
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Đăng nhập với Google',
                  onPressed: () async {
                    await auth.signInWithGoogle();
                    if (!mounted) return;
                    _showErrorIfAny(context, auth.error);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? '),
                    TextButton(
                      onPressed: () => context.navigateToSignUp(),
                      child: const Text('Đăng ký'),
                    ),
                  ],
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
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

