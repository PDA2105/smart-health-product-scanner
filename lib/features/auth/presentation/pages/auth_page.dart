import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Health - Auth'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đăng nhập'),
              Tab(text: 'Đăng ký'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LoginForm(),
            _SignUpForm(),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: _requiredEmail,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              label: 'Mật khẩu (>= 6 ký tự)',
              obscureText: true,
              validator: _requiredPassword,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Nhập lại mật khẩu',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập lại mật khẩu';
                }
                if (value != _passwordController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Tạo tài khoản',
              isLoading: auth.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                await auth.signUp(
                  _emailController.text.trim(),
                  _passwordController.text,
                );
                if (!mounted) return;
                _showErrorIfAny(context, auth.error);
              },
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
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

