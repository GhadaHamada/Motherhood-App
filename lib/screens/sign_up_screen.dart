import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController =
      TextEditingController(); // Controller for phone number
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String url = 'https://momshood.runasp.net/api/Account/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text, // Add phoneNumber here
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign Up Successful!')),
        );
        Navigator.pushNamed(context, '/login');
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Sign Up Failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up Failed: $errorMessage')),
        );
      }
    } catch (e) {
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
                        'Create Account',
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
                        _buildTextField(_firstNameController, 'First Name'),
                        _buildTextField(_lastNameController, 'Last Name'),
                        _buildTextField(_emailController, 'Email',
                            isEmail: true),
                        _buildTextField(_phoneNumberController, 'Phone Number',
                            isPhoneNumber: true), // Add phone number field
                        _buildTextField(_passwordController, 'Password',
                            isPassword: true, obscureText: _obscurePassword,
                            toggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        }),
                        _buildTextField(
                            _confirmPasswordController, 'Confirm Password',
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            toggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        }),
                        const SizedBox(height: 20),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    registerUser();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8D7D97),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text('Sign Up',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
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
      {bool isPassword = false,
      bool isEmail = false,
      bool isPhoneNumber = false, // Add this parameter
      bool obscureText = false,
      VoidCallback? toggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isPhoneNumber
            ? TextInputType.phone
            : TextInputType.text, // Set keyboard type for phone number
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
        validator: (value) {
          if (isPhoneNumber && value!.isEmpty) {
            return 'Please enter your phone number';
          }
          return null;
        },
      ),
    );
  }
}
/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String url = 'https://localhost:7054/api/Account/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        // لا حاجة لتخزين بيانات في SharedPreferences هنا

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign Up Successful!')),
        );
        Navigator.pushNamed(context, '/login');
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Sign Up Failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up Failed: $errorMessage')),
        );
      }
    } catch (e) {
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
                        'Sign Up',
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
                        _buildTextField(_firstNameController, 'First Name'),
                        _buildTextField(_lastNameController, 'Last Name'),
                        _buildTextField(_emailController, 'Email',
                            isEmail: true),
                        _buildTextField(_passwordController, 'Password',
                            isPassword: true, obscureText: _obscurePassword,
                            toggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        }),
                        _buildTextField(
                            _confirmPasswordController, 'Confirm Password',
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            toggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        }),
                        const SizedBox(height: 20),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    registerUser();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8D7D97),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text('Sign Up',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
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
      {bool isPassword = false,
      bool isEmail = false,
      bool obscureText = false,
      VoidCallback? toggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
*/
