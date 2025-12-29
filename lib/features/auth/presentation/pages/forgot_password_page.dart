import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
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
                if (!_emailSent) ...[
                  const Text(
                    'Nhập email của bạn để nhận link đặt lại mật khẩu',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _requiredEmail,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Gửi email đặt lại mật khẩu',
                    isLoading: auth.isLoading,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await auth.resetPassword(_emailController.text.trim());
                      if (!mounted) return;
                      if (auth.error == null) {
                        setState(() {
                          _emailSent = true;
                        });
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
                  ),
                ] else ...[
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Email đặt lại mật khẩu đã được gửi!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vui lòng kiểm tra hộp thư ${_emailController.text.trim()} và làm theo hướng dẫn.',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Gửi lại email',
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
                  ),
                ],
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.navigateToLogin(),
                  child: const Text('Quay lại đăng nhập'),
                ),
                if (auth.error != null && !_emailSent) ...[
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

void _showErrorIfAny(BuildContext context, String? error) {
  if (error == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
}

