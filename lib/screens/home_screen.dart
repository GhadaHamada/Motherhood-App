import 'package:flutter/material.dart';

import 'CommunityChatScreen.dart';
import 'MarketplaceScreen.dart';
import 'MomsGuideScreen.dart';
import 'VoiceRecognitionScreen.dart';
import 'ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // المتغير الذي يخزن الرقم المحدد في الشريط السفلي
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCBC3D6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  SizedBox(height: 16.0),
                  Center(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Image.asset(
                          'assets/images/bro.png',
                          height: 250,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            "Welcome to the mom's world",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            "Where love, care, and support come together for every mother.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "Services we provide",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _buildServiceItem(
                    context,
                    'Community chat >',
                    'assets/images/cuate.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityChatScreen(
                              //apiUrl: 'https://localhost:7054/api/Messages',
                              ),
                        ),
                      );
                    },
                  ),
                  _buildServiceItem(
                    context,
                    'Marketplace >',
                    'assets/images/baby.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MarketplaceScreen(),
                        ),
                      );
                    },
                  ),
                  _buildServiceItem(
                    context,
                    "Mom's guide >",
                    'assets/images/rafiki.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MomsGuideScreen(),
                        ),
                      );
                    },
                  ),
                  _buildServiceItem(
                    context,
                    'Voice recognition >',
                    'assets/images/pana.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoiceRecognitionScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 75, // تحديد الارتفاع
        width: 326, // تحديد العرض
        child: BottomNavigationBar(
          backgroundColor: Color(0xff8d7d9d), // لون الخلفية للشريط السفلي
          selectedItemColor: Color(0xffcbc3d6), // لون الأيقونة المحددة
          unselectedItemColor: Color(0xffcbc3d6), // لون الأيقونات غير المحددة
          showSelectedLabels: false, // إخفاء النصوص
          showUnselectedLabels: false, // إخفاء النصوص
          type: BottomNavigationBarType.fixed,
          currentIndex:
              _selectedIndex, // تعيين الأيقونة المحددة بناءً على الفهرس
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            // تحديد الصفحات حسب الأيقونة التي يتم الضغط عليها
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityChatScreen(
                        //apiUrl: 'https://localhost:7054/api/Messages',
                        ),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MomsGuideScreen(),
                  ),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoiceRecognitionScreen(),
                  ),
                );
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarketplaceScreen(),
                  ),
                );
                break;
              case 5:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                        //token: 'https://localhost:7054/api/Account/register',
                        ),
                  ),
                );
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildHomeIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
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
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String title, String imagePath,
      {void Function()? onTap}) {
    return Column(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            imagePath,
            width: 120, // تكبير عرض الصورة
            height: 120, // تكبير ارتفاع الصورة
          ),
        ),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  // تخصيص أيقونة home داخل دائرة
  Widget _buildHomeIcon() {
    return Container(
      width: 40.0, // حجم الدائرة
      height: 40.0, // حجم الدائرة
      decoration: BoxDecoration(
        color: Color(0xffCBC3D6), // لون الدائرة (نفس لون الخلفية)
        shape: BoxShape.circle, // الشكل دائري
      ),
      child: Icon(
        Icons.home,
        color: Colors.white, // لون الأيقونة
        size: 24.0, // حجم الأيقونة
      ),
    );
  }
}
