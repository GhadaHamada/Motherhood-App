import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String email; // البريد الإلكتروني
  final String resetCode; // رمز التحقق

  const ResetPasswordScreen(
      {required this.email, required this.resetCode, Key? key})
      : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController =
      TextEditingController(); // تحكم في حقل إدخال كلمة المرور الجديدة
  final _confirmPasswordController =
      TextEditingController(); // تحكم في حقل تأكيد كلمة المرور
  bool _obscureNewPassword = true; // لإخفاء أو إظهار كلمة المرور الجديدة
  bool _obscureConfirmPassword = true; // لإخفاء أو إظهار تأكيد كلمة المرور

  Future<void> _resetPassword(BuildContext context) async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور غير متطابقة.')),
      );
      return;
    }

    final url =
        Uri.parse('https://momshood.runasp.net/api/Account/reset-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': widget.email,
      'resetCode': widget.resetCode,
      'newPassword': newPassword,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // إذا نجح الطلب
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة تعيين كلمة المرور بنجاح.')),
        );
        // توجيه المستخدم إلى صفحة تسجيل الدخول
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // إذا فشل الطلب
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $errorMessage')),
        );
      }
    } catch (e) {
      // معالجة الأخطاء العامة
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF8D7D97),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Image.asset('assets/images/back (1).png',
                      width: 30, height: 30),
                  iconSize: 50,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Frame 94.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Please enter your new password to Please enter your new password to continue',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword =
                                            !_obscureNewPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      // زر Reset Password داخل الجزء الأبيض وفي أسفله
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            _resetPassword(
                                context); // استدعاء دالة إعادة تعيين كلمة المرور
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D7D97),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            minimumSize: const Size(
                                double.infinity, 50), // لجعل الزر عريض
                          ),
                          child: const Text(
                            'Reset Password',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatelessWidget {
  final String email; // البريد الإلكتروني
  final String resetCode; // رمز التحقق
  final _newPasswordController =
      TextEditingController(); // تحكم في حقل إدخال كلمة المرور الجديدة
  final _confirmPasswordController =
      TextEditingController(); // تحكم في حقل تأكيد كلمة المرور

  ResetPasswordScreen({required this.email, required this.resetCode});

  Future<void> _resetPassword(BuildContext context) async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء ملء جميع الحقول.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('كلمة المرور غير متطابقة.')),
      );
      return;
    }

    final url = Uri.parse('https://localhost:7054/api/Account/reset-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'resetCode': resetCode,
      'newPassword': newPassword,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // إذا نجح الطلب
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إعادة تعيين كلمة المرور بنجاح.')),
        );
        // توجيه المستخدم إلى صفحة تسجيل الدخول
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // إذا فشل الطلب
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $errorMessage')),
        );
      }
    } catch (e) {
      // معالجة الأخطاء العامة
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reset your password',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _resetPassword(context); // استدعاء دالة إعادة تعيين كلمة المرور
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}*/
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatelessWidget {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final String email; // البريد الإلكتروني الذي تم إرسال الرمز إليه
  final String resetCode; // رمز التحقق

  ResetPasswordScreen({required this.email, required this.resetCode});

  Future<void> _resetPassword(BuildContext context) async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال كلمة المرور وتأكيدها.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('كلمة المرور غير متطابقة.')),
      );
      return;
    }

    final url = Uri.parse('https://localhost:7054/api/Account/reset-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'resetCode': resetCode,
      'newPassword': newPassword,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // إذا نجح الطلب
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إعادة تعيين كلمة المرور بنجاح.')),
        );
        // توجيه المستخدم إلى صفحة تسجيل الدخول
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // إذا فشل الطلب
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $errorMessage')),
        );
      }
    } catch (e) {
      // معالجة الأخطاء العامة
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your new password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your new password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _resetPassword(context);
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}*/
