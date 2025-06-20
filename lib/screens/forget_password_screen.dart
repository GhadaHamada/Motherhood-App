import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'VerificationCodeScreen.dart';

class ForgetPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  Future<void> _sendResetCode(String email, BuildContext context) async {
    final url =
        Uri.parse('https://momshood.runasp.net/api/Account/forget-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // إذا نجح الطلب
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني.')),
        );
        // توجيه المستخدم إلى صفحة إدخال رمز التحقق
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(email: email),
          ),
        );
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF8D7D97), // الخلفية بلون مشابه
          ),
          child: Column(
            children: [
              // زر الرجوع
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: Image.asset('assets/images/back (1).png',
                        width: 30, height: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // صورة توضيحية
              Center(
                child: Image.asset(
                  'assets/images/Frame 2912.png',
                  width: 200,
                  height: 200,
                ),
              ),

              // النموذج (الحاوية البيضاء)
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // محاذاة العناصر إلى الأسفل
                    children: [
                      // العنوان والوصف
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D7D97),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please enter your email so we can\n send you a verification code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff757575),
                        ),
                      ),
                      SizedBox(height: 20),

                      // حقل إدخال البريد الإلكتروني
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: '@example.com',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon:
                              Icon(Icons.email, color: Color(0xFF757575)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // زر إرسال رمز إعادة التعيين
                      ElevatedButton(
                        onPressed: () {
                          final email = _emailController.text.trim();
                          if (email.isNotEmpty) {
                            _sendResetCode(email, context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('الرجاء إدخال البريد الإلكتروني.')),
                            );
                          }
                        },
                        child: Text(
                          'Send reset code',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8D7D97),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 100.0),
                        ),
                      ),
                      SizedBox(height: 20),

                      // زر العودة لتسجيل الدخول
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF5E478D),
                            ),
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

import 'VerificationCodeScreen.dart';
import 'VoiceRecognitionScreen.dart'; // استيراد صفحة VoiceRecognitionScreen

class ForgetPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  Future<void> _sendResetCode(String email, BuildContext context) async {
    final url = Uri.parse('https://localhost:7054/api/Account/forget-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // إذا نجح الطلب
        print('Reset code sent to: $email');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني.')),
        );
        // توجيه المستخدم إلى صفحة VoiceRecognitionScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(email: email),
          ),
        );
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF8D7D97), // الخلفية بلون مشابه
          ),
          child: Column(
            children: [
              // زر الرجوع
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: Image.asset('assets/images/back (1).png',
                        width: 30, height: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // صورة توضيحية
              Center(
                child: Image.asset(
                  'assets/images/Frame 2912.png',
                  width: 200,
                  height: 200,
                ),
              ),

              // النموذج (الحاوية البيضاء)
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // محاذاة العناصر إلى الأسفل
                    children: [
                      // العنوان والوصف
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D7D97),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please enter your email so we can\n send you a verification code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff757575),
                        ),
                      ),
                      SizedBox(height: 20),

                      // حقل إدخال البريد الإلكتروني
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: '@example.com',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon:
                              Icon(Icons.email, color: Color(0xFF757575)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // زر إرسال رمز إعادة التعيين
                      ElevatedButton(
                        onPressed: () {
                          final email = _emailController.text.trim();
                          if (email.isNotEmpty) {
                            _sendResetCode(email, context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('الرجاء إدخال البريد الإلكتروني.')),
                            );
                          }
                        },
                        child: Text(
                          'Send reset code',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8D7D97),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 100.0),
                        ),
                      ),
                      SizedBox(height: 20),

                      // زر العودة لتسجيل الدخول
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF5E478D),
                            ),
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
}*/
/*import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF8D7D97), // الخلفية بلون مشابه
          ),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: Image.asset('assets/images/back (1).png',
                        width: 30, height: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Illustration image
              Center(
                child: Image.asset(
                  'assets/images/Frame 2912.png',
                  width: 200,
                  height: 200,
                ),
              ),

              // White container for form fields (includes title and description)
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align to the bottom
                    children: [
                      // Title and description (now part of the white container)
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D7D97),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please enter your email so we can\n send you a verification code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff757575),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Email input field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: '@example.com',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon:
                              Icon(Icons.email, color: Color(0xFF757575)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Reset Password button
                      ElevatedButton(
                        onPressed: () {
                          // Handle password reset logic here
                          print('Reset link sent to: ${_emailController.text}');
                        },
                        child: Text(
                          'Send reset code',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8D7D97),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 100.0),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Back to login button (inside white container)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF5E478D),
                            ),
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
}*/
