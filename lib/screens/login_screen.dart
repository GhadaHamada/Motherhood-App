/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool isLoading = false;

  // دالة للتحقق من صحة الـ token
  Future<bool> validateToken(String token) async {
    final String url = 'https://momshood.runasp.net/api/Account/validate-token';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['isValid'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  // دالة تسجيل الدخول
  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    final String url = 'https://momshood.runasp.net/api/Account/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        final userId = responseData['id'];
        final firstName = responseData['firstName'];
        final lastName = responseData['lastName'];
        final phoneNumber = responseData['phoneNumber'] ??
            ''; // جلب phoneNumber أو تعيين قيمة افتراضية

        if (token != null &&
            userId != null &&
            firstName != null &&
            lastName != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('id', userId);
          await prefs.setString('email', _emailController.text);
          await prefs.setString('first_name', firstName);
          await prefs.setString('last_name', lastName);
          await prefs.setString('phone_number', phoneNumber); // حفظ phoneNumber

          // التحقق من صحة الـ token
          bool isValid = await validateToken(token);
          if (isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful!')),
            );

            Navigator.pushReplacementNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Invalid Token. Please login again.')),
            );
          }
        }
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Login Failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: $errorMessage')),
        );
      }
    } catch (e) {
      print('Error logging in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF8D7D97),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(_emailController, 'Email',
                            isEmail: true),
                        _buildPasswordField(_passwordController, 'Password'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                      color: Color(0xff757575), fontSize: 11),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/forget_password');
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: Color(0xff757575),
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    loginUser();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8D7D97),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text('Login',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('or'),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.apple,
                              size: 40,
                              color: Color(0xff999999),
                            ),
                            const SizedBox(width: 20),
                            Image.asset(
                              'assets/images/Google.png',
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              FontAwesomeIcons.facebook,
                              size: 30,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child:
                                const Text('Don\'t have an Account? Register'),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'Please enter your $label';
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'Please enter your $label';
          return null;
        },
      ),
    );
  }
}
*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isCheckingToken = true;

  // Colors
  static const Color _primaryColor = Color(0xFF8D7D97);
  static const Color _textGray = Color(0xFF757575);
  static const Color _backgroundGray = Color(0xFFF5F5F5);

  // API URLs
  static const String _baseUrl = 'https://momshood.runasp.net/api/';
  static const String _loginUrl = '${_baseUrl}Account/login';
  static const String _validateTokenUrl = '${_baseUrl}Account/validate-token';

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool rememberMe = prefs.getBool('remember_me') ?? false;
      final String? token = prefs.getString('token');

      if (rememberMe && token != null) {
        final isValid = await _validateToken(token);
        if (isValid && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
      }
    } catch (e) {
      debugPrint('Error checking saved login: $e');
    } finally {
      if (mounted) {
        setState(() => _isCheckingToken = false);
      }
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse(_validateTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['isValid'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final userId = responseData['id'];
        final firstName = responseData['firstName'];
        final lastName = responseData['lastName'];
        final phoneNumber = responseData['phoneNumber'] ?? '';

        if (token != null &&
            userId != null &&
            firstName != null &&
            lastName != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('id', userId);
          await prefs.setString('email', _emailController.text.trim());
          await prefs.setString('first_name', firstName);
          await prefs.setString('last_name', lastName);
          await prefs.setString('phone_number', phoneNumber);
          await prefs.setBool('remember_me', _rememberMe);

          final isValid = await _validateToken(token);
          if (isValid && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful!')),
            );
            Navigator.pushReplacementNamed(context, '/home');
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Invalid Token. Please login again.')),
            );
            await prefs.remove('token');
            await prefs.remove('remember_me');
          }
        } else {
          throw Exception('Missing required user data');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Login Failed';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Failed: $errorMessage')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingToken) {
      return const Scaffold(
        backgroundColor: _primaryColor,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top purple section
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/Frame 94.png',
                    width: screenWidth * 0.35,
                    height: screenWidth * 0.35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // White section filling the rest of the screen
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.03,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight * 0.6,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8D7D97),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            isEmail: true,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            isPassword: true,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() => _rememberMe = value!);
                                    },
                                    activeColor: _primaryColor,
                                  ),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                        color: _textGray, fontSize: 12),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/forget_password');
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: _textGray,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: _primaryColor),
                                )
                              : ElevatedButton(
                                  onPressed: _isLoading ? null : _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.02),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Login'),
                                ),
                          SizedBox(height: screenHeight * 0.025),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              "Don't have an Account? Register",
                              style: TextStyle(color: _textGray),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: _backgroundGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: _textGray,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your $label';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (isPassword && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
