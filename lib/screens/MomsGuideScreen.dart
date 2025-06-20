import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'CommunityChatScreen.dart';
import 'MarketplaceScreen.dart';
import 'ProfileScreen.dart';
import 'VoiceRecognitionScreen.dart';
import 'home_screen.dart';

class MomsGuideScreen extends StatefulWidget {
  @override
  _MomsGuideScreenState createState() => _MomsGuideScreenState();
}

class _MomsGuideScreenState extends State<MomsGuideScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Widget> _screens = [
    HomeScreen(),
    CommunityChatScreen(),
    MomsGuideScreen(),
    VoiceRecognitionScreen(),
    MarketplaceScreen(),
    ProfileScreen(),
  ];

  List<dynamic> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _fetchRandomTips(); // جلب النصائح عند بدء الصفحة
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _screens[index]),
      );
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _fetchRandomTips() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to login first!')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('https://momshood.runasp.net/api/BabyRecord/RandomTips'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _tips = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tips')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C6E0),
      appBar: AppBar(
        backgroundColor: Color(0xFFD2C6E0),
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 30, height: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Image.asset(
                        'assets/images/Ellipse 11 (2).png',
                        height: 200,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: _tips.map((tip) {
                            return _buildInfoCard(
                              title: tip['title'],
                              content: tip['description'],
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff8d7d9d),
        selectedItemColor: Color(0xffcbc3d6),
        unselectedItemColor: Color(0xffcbc3d6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildHomeIcon(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 28,
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Color(0xffD9D9D9),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              content,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeIcon() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: Color(0xffCBC3D6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.menu_book,
        color: Colors.white,
        size: 24.0,
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

import 'CommunityChatScreen.dart';
import 'MarketplaceScreen.dart';
import 'ProfileScreen.dart';
import 'VoiceRecognitionScreen.dart';
import 'home_screen.dart';

class MomsGuideScreen extends StatefulWidget {
  @override
  _MomsGuideScreenState createState() => _MomsGuideScreenState();
}

class _MomsGuideScreenState extends State<MomsGuideScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Widget> _screens = [
    HomeScreen(),
    CommunityChatScreen(
        //apiUrl: 'https://localhost:7054/api/Messages',
        ),
    MomsGuideScreen(),
    VoiceRecognitionScreen(),
    MarketplaceScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _screens[index]),
      );
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C6E0),
      appBar: AppBar(
        backgroundColor: Color(0xFFD2C6E0),
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 30, height: 30),
          iconSize: 50,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Image.asset(
                        'assets/images/Ellipse 11 (2).png',
                        height: 200,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _buildInfoCard(
                      title: "Baby Care Tips",
                      content:
                          "Baby care involves providing proper nutrition, adequate sleep, and personal hygiene. It also includes regular medical check-ups, ensuring a safe environment, and supporting mental and social development through interaction and play. The goal is to ensure the child’s physical and mental health."),
                  SizedBox(height: 16.0),
                  _buildInfoCard(
                    title: "Nutrition Advices",
                    content:
                        "Breastfeeding is the primary source of nutrition for the first 6 months. If not possible, infant formula is recommended. After 6 months, introduce solid foods like iron-rich pureed vegetables, fruits, and cereals. Avoid honey and whole nuts in the first year. Ensure the baby stays hydrated with water and consult a pediatrician for personalized advice.",
                  ),
                  SizedBox(height: 16.0),
                  _buildInfoCard(
                      title: "Health Guideline",
                      content:
                          "Child health guidelines focus on providing proper nutrition, adequate sleep, and appropriate physical activity. Regular medical check-ups and vaccinations are essential. It’s important to ensure a safe and clean environment, and avoid smoking and alcohol around the child. Mental health should also be supported through positive interaction and play."),
                  SizedBox(height: 16.0),
                  _buildInfoCard(
                      title: "Sleep & Routine Tips",
                      content:
                          "Establish a consistent bedtime routine that includes dim lighting, soothing music, and gentle calming techniques such as soft patting or low humming to help your baby feel relaxed and ready for sleep."),
                  SizedBox(height: 16.0),
                  _buildInfoCard(
                      title: "Emotional Bonding",
                      content:
                          "Hold your baby close and often to provide comfort and strengthen your emotional connection. Talk to your baby in a calm and soothing voice to help them feel secure and loved. Respond to your baby’s cries promptly to build trust and reinforce your bond. Spend quality time with your baby, even during daily routines, to enhance your emotional connection."),
                  SizedBox(height: 16.0),
                  _buildInfoCard(
                      title: "Safety at Home",
                      content:
                          "Always place your baby on their back to sleep, keep harmful substances out of reach, use baby gates and secure furniture to prevent accidents, ensure the crib has a firm mattress with no loose bedding or toys, and cover electrical outlets while keeping cords out of reach to ensure safety at home."),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff8d7d9d),
        selectedItemColor: Color(0xffcbc3d6),
        unselectedItemColor: Color(0xffcbc3d6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildHomeIcon(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 28,
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xffD9D9D9),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              content,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHomeIcon() {
  return Container(
    width: 40.0,
    height: 40.0,
    decoration: BoxDecoration(
      color: Color(0xffCBC3D6),
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.menu_book,
      color: Colors.white,
      size: 24.0,
    ),
  );
}
*/
