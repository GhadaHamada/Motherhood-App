import 'package:flutter/material.dart';
import 'ResetPasswordScreen.dart';

class VerificationCodeScreen extends StatelessWidget {
  final String email; // البريد الإلكتروني
  final _codeController =
      TextEditingController(); // تحكم في حقل إدخال رمز التحقق

  VerificationCodeScreen({required this.email});

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
                      'assets/images/tasklist.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Verification Code',
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
                                'We have sent you a code to verify your email address',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _codeController,
                                decoration: InputDecoration(
                                  labelText: 'Verification Code',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () {
                                  // إعادة إرسال الرمز
                                },
                                child: const Text(
                                  'Don\'t receive the code? Resend Code',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      // زر Verify داخل الجزء الأبيض وفي أسفله
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            final code = _codeController.text.trim();
                            if (code.isNotEmpty) {
                              // توجيه المستخدم إلى صفحة إعادة تعيين كلمة المرور
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordScreen(
                                    email: email, // تمرير البريد الإلكتروني
                                    resetCode: code, // تمرير رمز التحقق
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('الرجاء إدخال رمز التحقق.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D7D97),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            minimumSize: const Size(
                                double.infinity, 50), // لجعل الزر عريض
                          ),
                          child: const Text('Verify',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
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
import 'ResetPasswordScreen.dart';

class VerificationCodeScreen extends StatelessWidget {
  final String email; // البريد الإلكتروني
  final _codeController =
      TextEditingController(); // تحكم في حقل إدخال رمز التحقق

  VerificationCodeScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'We have sent you a code to verify your email address',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // إعادة إرسال الرمز
              },
              child: Text(
                'Don\'t receive the code? Resend Code',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final code = _codeController.text.trim();
                if (code.isNotEmpty) {
                  // توجيه المستخدم إلى صفحة إعادة تعيين كلمة المرور
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPasswordScreen(
                        email: email, // تمرير البريد الإلكتروني
                        resetCode: code, // تمرير رمز التحقق
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('الرجاء إدخال رمز التحقق.')),
                  );
                }
              },
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
} */
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationCodeScreen extends StatelessWidget {
  final String email; // البريد الإلكتروني الذي تم إرسال الرمز إليه
  final _codeController =
      TextEditingController(); // تحكم في حقل إدخال رمز التحقق
  final _newPasswordController =
      TextEditingController(); // تحكم في حقل إدخال كلمة المرور الجديدة
  final _confirmPasswordController =
      TextEditingController(); // تحكم في حقل تأكيد كلمة المرور

  VerificationCodeScreen({required this.email});

  // دالة للتحقق من رمز التحقق وإعادة تعيين كلمة المرور
  Future<void> _resetPassword(BuildContext context) async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
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
      'resetCode': code,
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
        title: Text('Enter Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter the verification code sent to $email'),
            SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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

class VerificationCodeScreen extends StatelessWidget {
  final String email; // البريد الإلكتروني الذي تم إرسال الرمز إليه
  final _codeController =
      TextEditingController(); // تحكم في حقل إدخال رمز التحقق

  VerificationCodeScreen({required this.email});

  // دالة للتحقق من رمز التحقق
  void _verifyCode(BuildContext context) {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      // إذا كان حقل رمز التحقق فارغًا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال رمز التحقق.')),
      );
      return;
    }

    // هنا يمكنك إضافة منطق للتحقق من صحة رمز التحقق (مثل الاتصال بالسيرفر)
    // لنفترض أن الرمز الصحيح هو "123456" (يمكنك تغييره حسب الحاجة)
    if (code == "123456") {
      // إذا كان رمز التحقق صحيحًا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التحقق من الرمز بنجاح.')),
      );

      // توجيه المستخدم إلى صفحة إعادة تعيين كلمة المرور
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: email),
        ),
      );
    } else {
      // إذا كان رمز التحقق غير صحيح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رمز التحقق غير صحيح.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter the verification code sent to $email'),
            SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _verifyCode(context); // استدعاء دالة التحقق من رمز التحقق
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// صفحة إعادة تعيين كلمة المرور (لأغراض التوضيح)
class ResetPasswordScreen extends StatelessWidget {
  final String email;

  ResetPasswordScreen({required this.email});

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
            Text('Reset your password for $email'),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // يمكنك هنا إضافة منطق لإعادة تعيين كلمة المرور
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

class VerificationCodeScreen extends StatelessWidget {
  final String email; // البريد الإلكتروني الذي تم إرسال الرمز إليه

  VerificationCodeScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter the verification code sent to $email'),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // يمكنك هنا إضافة منطق للتحقق من رمز التحقق
              },
              child: Text('Submit'),
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

class VerificationCodeScreen extends StatelessWidget {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final String email; // البريد الإلكتروني الذي تم إرسال الرمز إليه

  VerificationCodeScreen({required this.email});

  // إضافة BuildContext كمعامل للدالة
  Future<void> _resetPassword(BuildContext context, String email, String code,
      String newPassword) async {
    final url = Uri.parse('https://localhost:7054/api/Account/reset-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'resetCode': code,
      'newPassword': newPassword,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // إذا نجح الطلب
        print('Password reset successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إعادة تعيين كلمة المرور بنجاح.')),
        );
        // توجيه المستخدم إلى صفحة تسجيل الدخول
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // إذا فشل الطلب
        final errorMessage = jsonDecode(response.body)['message'];
        print('Error: $errorMessage');
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
        title: Text('Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                hintText: 'Enter the code sent to your email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
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
                final code = _codeController.text.trim();
                final newPassword = _newPasswordController.text.trim();
                final confirmPassword = _confirmPasswordController.text.trim();

                if (code.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
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

                // تمرير context هنا
                _resetPassword(context, email, code, newPassword);
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}*/
