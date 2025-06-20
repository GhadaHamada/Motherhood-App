/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String token = '';
  int _selectedIndex =
      5; // Track the selected index in the bottom navigation bar

  // وظيفة لتحميل البيانات الشخصية من SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? ''; // جلب firstName
      lastName = prefs.getString('last_name') ?? ''; // جلب lastName
      email = prefs.getString('email') ?? ''; // جلب email
      //token = prefs.getString('token') ?? ''; // جلب token
    });
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
  void initState() {
    super.initState();
    _loadProfileData(); // تحميل البيانات عند بدء الصفحة
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
            child: Text("Profile",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 26, height: 26),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 70),
          // الجزء الأبيض الذي يبدأ من أسفل الـ AppBar ويمتد حتى الـ Bottom Navigation Bar
          Expanded(
            child: SingleChildScrollView(
              // إضافة SingleChildScrollView
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF8D7D9D),
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : '',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Good Morning.",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 5),
                      Text(
                        "$firstName $lastName", // عرض الاسم الأول والاسم الأخير
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                      SizedBox(height: 20),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Personal Information",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      _buildProfileDetail("First Name", firstName),
                      _buildProfileDetail("Last Name", lastName),
                      _buildProfileDetail("Email", email),
                      //_buildProfileDetail("Token", token), // عرض التوكن
                      SizedBox(height: 20),
                      // أزرار Edit Profile و Sign Out
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // هنا يمكنك فتح شاشة تعديل البيانات الشخصية
                              Navigator.pushNamed(context,
                                  '/editProfile'); // فتح شاشة لتعديل الملف الشخصي
                            },
                            icon: Icon(Icons.edit, color: Color(0xFF8D7D9D)),
                            label: Text("Edit Profile"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF8D7D9D),
                              side: BorderSide(color: Color(0xFF8D7D9D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // عملية تسجيل الخروج
                              await _signOut();
                              Navigator.pushReplacementNamed(context,
                                  '/login'); // العودة إلى شاشة تسجيل الدخول
                            },
                            icon: Icon(Icons.logout, color: Color(0xFF8D7D9D)),
                            label: Text("Sign Out"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF8D7D9D),
                              side: BorderSide(color: Color(0xFF8D7D9D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 16)),
          Flexible(
            child: Text(value,
                style: TextStyle(color: Colors.black, fontSize: 16),
                overflow:
                    TextOverflow.ellipsis), // لمنع التوكن الطويل من كسر التصميم
          ),
        ],
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

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // مسح بيانات المستخدم من SharedPreferences
  }
}*/
/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = ''; // إضافة متغير phoneNumber
  String token = '';
  int _selectedIndex =
      5; // Track the selected index in the bottom navigation bar

  // وظيفة لتحميل البيانات الشخصية من SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? ''; // جلب firstName
      lastName = prefs.getString('last_name') ?? ''; // جلب lastName
      email = prefs.getString('email') ?? ''; // جلب email
      phoneNumber = prefs.getString('phone_number') ?? ''; // جلب phoneNumber
      //token = prefs.getString('token') ?? ''; // جلب token
    });

    print("Phone Number: $phoneNumber"); // طباعة رقم الهاتف للتحقق
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
  void initState() {
    super.initState();
    _loadProfileData(); // تحميل البيانات عند بدء الصفحة
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
            child: Text("Profile",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 26, height: 26),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 70),
          // الجزء الأبيض الذي يبدأ من أسفل الـ AppBar ويمتد حتى الـ Bottom Navigation Bar
          Expanded(
            child: SingleChildScrollView(
              // إضافة SingleChildScrollView
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF8D7D9D),
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : '',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Good Morning.",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 5),
                      Text(
                        "$firstName $lastName", // عرض الاسم الأول والاسم الأخير
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                      SizedBox(height: 20),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Personal Information",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      _buildProfileDetail("First Name", firstName),
                      _buildProfileDetail("Last Name", lastName),
                      _buildProfileDetail("Email", email),
                      _buildProfileDetail(
                          "Phone Number", phoneNumber), // عرض phoneNumber
                      //_buildProfileDetail("Token", token), // عرض التوكن
                      SizedBox(height: 20),
                      // أزرار Edit Profile و Sign Out
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // هنا يمكنك فتح شاشة تعديل البيانات الشخصية
                              Navigator.pushNamed(context,
                                  '/editProfile'); // فتح شاشة لتعديل الملف الشخصي
                            },
                            icon: Icon(Icons.edit, color: Color(0xFF8D7D9D)),
                            label: Text("Edit Profile"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF8D7D9D),
                              side: BorderSide(color: Color(0xFF8D7D9D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // عملية تسجيل الخروج
                              await _signOut();
                              Navigator.pushReplacementNamed(context,
                                  '/login'); // العودة إلى شاشة تسجيل الدخول
                            },
                            icon: Icon(Icons.logout, color: Color(0xFF8D7D9D)),
                            label: Text("Sign Out"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF8D7D9D),
                              side: BorderSide(color: Color(0xFF8D7D9D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 16)),
          Flexible(
            child: Text(value,
                style: TextStyle(color: Colors.black, fontSize: 16),
                overflow:
                    TextOverflow.ellipsis), // لمنع التوكن الطويل من كسر التصميم
          ),
        ],
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

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // مسح بيانات المستخدم من SharedPreferences

    // إذا كنت تستخدم Firebase أو أي خدمة أخرى، يمكنك إضافتها هنا أيضًا.
    // على سبيل المثال:
    // await FirebaseAuth.instance.signOut();
  }
}*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  int _selectedIndex = 5;

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
      email = prefs.getString('email') ?? '';
    });
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
  void initState() {
    super.initState();
    _loadProfileData();
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
            child: Text("Profile",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 26, height: 26),
          onPressed: () {
            Navigator.pop(context);
          },
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 60),
                          Text(
                            "$firstName $lastName",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                          SizedBox(height: 20),
                          Divider(color: Colors.grey.shade300),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Personal Information",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 10),
                          _buildProfileDetail("First Name", firstName),
                          _buildProfileDetail("Last Name", lastName),
                          _buildProfileDetail("Email", email),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/editProfile');
                                },
                                icon:
                                    Icon(Icons.edit, color: Color(0xFF8D7D9D)),
                                label: Text("Edit Profile"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF8D7D9D),
                                  side: BorderSide(color: Color(0xFF8D7D9D)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _signOut();
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                                icon: Icon(Icons.logout,
                                    color: Color(0xFF8D7D9D)),
                                label: Text("Sign Out"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF8D7D9D),
                                  side: BorderSide(color: Color(0xFF8D7D9D)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // الدائرة الجديدة بموقع وألوان زي الكود السابق
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : '',
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

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 16)),
          Flexible(
            child: Text(value,
                style: TextStyle(color: Colors.black, fontSize: 16),
                overflow: TextOverflow.ellipsis),
          ),
        ],
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

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
