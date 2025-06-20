/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  int _selectedIndex =
      5; // Track the selected index in the bottom navigation bar

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('first_name') ?? '';
      _lastNameController.text = prefs.getString('last_name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
    });
  }

  Future<void> _updateProfile() async {
    try {
      if (_firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty ||
          _emailController.text.isEmpty) {
        throw Exception("All fields are required!");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_name', _firstNameController.text);
      await prefs.setString('last_name', _lastNameController.text);
      await prefs.setString('email', _emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on the selected index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/community_chat');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/moms_guide');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/voice_recognition');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/marketplace');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8D7D9D),
      appBar: AppBar(
        backgroundColor: Color(0xFF8D7D9D),
        elevation: 0,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 26, height: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 70),
          // الجزء الأبيض الذي يبدأ من أسفل الـ AppBar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // الدائرة مع الحرف الأول من الاسم
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF8D7D9D),
                          child: Text(
                            _firstNameController.text.isNotEmpty
                                ? _firstNameController.text[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Update Your Information",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 10),
                      // الحقول النصية
                      _buildTextField("First Name", _firstNameController),
                      SizedBox(height: 20),
                      _buildTextField("Last Name", _lastNameController),
                      SizedBox(height: 20),
                      _buildTextField("Email", _emailController),
                      SizedBox(height: 40),
                      // زر الحفظ
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8D7D9D),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF8D7D9D)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Color(0xFF8D7D9D),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.chat, 1),
          _buildNavItem(Icons.menu_book, 2),
          _buildNavItem(Icons.mic, 3),
          _buildNavItem(Icons.shopping_cart, 4),
          _buildNavItem(Icons.person, 5),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isSelected ? Color(0xffCBC3D6) : Colors.transparent,
        child: Icon(
          icon,
          color: isSelected ? Color(0xFFffffff) : Color(0xffCBC3D6),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  int _selectedIndex = 5;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('first_name') ?? '';
      _lastNameController.text = prefs.getString('last_name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
    });
  }

  Future<void> _updateProfile() async {
    try {
      setState(() => _isUpdating = true);

      if (_firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty ||
          _emailController.text.isEmpty) {
        throw Exception("All fields are required!");
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_emailController.text)) {
        throw Exception("Please enter a valid email address");
      }

      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("You need to login first!");
      }

      final response = await http.put(
        Uri.parse('https://momshood.runasp.net/api/Account/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        await prefs.setString('first_name', _firstNameController.text);
        await prefs.setString('last_name', _lastNameController.text);
        await prefs.setString('email', _emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Failed to update profile';
        throw Exception(errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/community_chat');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/moms_guide');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/voice_recognition');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/marketplace');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8D7D9D),
      appBar: AppBar(
        backgroundColor: Color(0xFF8D7D9D),
        elevation: 0,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 26, height: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 100,
                color: Color(0xFF8D7D9D),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32.0)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        Text(
                          "Update Your Information",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildFloatingTextField(
                            "First Name", _firstNameController),
                        SizedBox(height: 20),
                        _buildFloatingTextField(
                            "Last Name", _lastNameController),
                        SizedBox(height: 20),
                        _buildFloatingTextField("Email", _emailController),
                        SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _updateProfile,
                            child: _isUpdating
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8D7D9D),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// Avatar الدائري
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                _firstNameController.text.isNotEmpty
                    ? _firstNameController.text[0].toUpperCase()
                    : '',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFloatingTextField(
      String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF8D7D9D)),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Color(0xFF8D7D9D),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.chat, 1),
          _buildNavItem(Icons.menu_book, 2),
          _buildNavItem(Icons.mic, 3),
          _buildNavItem(Icons.shopping_cart, 4),
          _buildNavItem(Icons.person, 5),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isSelected ? Color(0xffCBC3D6) : Colors.transparent,
        child: Icon(
          icon,
          color: isSelected ? Color(0xFFffffff) : Color(0xffCBC3D6),
        ),
      ),
    );
  }
}
