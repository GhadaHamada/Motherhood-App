import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/community_chat');
        break;
      case 2:
        Navigator.pushNamed(context, '/moms_guide');
        break;
      case 3:
        Navigator.pushNamed(context, '/voice_recognition');
        break;
      case 4:
        Navigator.pushNamed(context, '/marketplace');
        break;
      case 5:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح تطبيق الهاتف')),
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = 'https://wa.me/$cleanedNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح تطبيق الواتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCBC3D6), Color(0xFFD8BFD8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Image.asset('assets/images/back (1).png',
                    width: 30, height: 30),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.product['title'],
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صورة المنتج
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: widget.product['image'].isEmpty
                            ? Icon(Icons.image_not_supported,
                                size: 60, color: Colors.grey)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.product['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported,
                                        size: 60, color: Colors.grey);
                                  },
                                ),
                              ),
                      ),
                      SizedBox(height: 20),

                      // عنوان المنتج
                      Text(
                        widget.product['title'],
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 8),

                      // حالة المنتج
                      Text(
                        widget.product['state'],
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 16),

                      // السعر
                      Text(
                        widget.product['price'],
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 20),

                      // وصف المنتج
                      Text(
                        'Description:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.product['description'],
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 20),

                      // معلومات البائع
                      Text(
                        'Seller Information:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.product['userName'],
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 20),

                      // معلومات الاتصال
                      Text(
                        'Contact Seller:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10),

                      // بيانات الاتصال الهاتفي
                      Row(
                        children: [
                          Icon(Icons.phone, color: Color(0xFF8D7D97)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.product['phoneNumber'],
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.call, color: Color(0xFF8D7D97)),
                            onPressed: () =>
                                _makePhoneCall(widget.product['phoneNumber']),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // بيانات الواتساب
                      Row(
                        children: [
                          Icon(Icons.chat, color: Color(0xFF8D7D97)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.product['whatsappNumber'],
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: Color(0xFF8D7D97)),
                            onPressed: () =>
                                _openWhatsApp(widget.product['whatsappNumber']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 60,
              width: double.infinity,
              color: Color(0xFF8D7D97),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.home, color: Colors.white),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    icon: Icon(Icons.chat, color: Colors.white),
                    onPressed: () => _onItemTapped(1),
                  ),
                  IconButton(
                    icon: Icon(Icons.menu_book, color: Colors.white),
                    onPressed: () => _onItemTapped(2),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.white),
                    onPressed: () => _onItemTapped(3),
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () => _onItemTapped(4),
                  ),
                  IconButton(
                    icon: Icon(Icons.person, color: Colors.white),
                    onPressed: () => _onItemTapped(5),
                  ),
                ],
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
        Icons.home,
        color: Colors.white,
        size: 24.0,
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/community_chat');
        break;
      case 2:
        Navigator.pushNamed(context, '/moms_guide');
        break;
      case 3:
        Navigator.pushNamed(context, '/voice_recognition');
        break;
      case 4:
        Navigator.pushNamed(context, '/marketplace');
        break;
      case 5:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // تنظيف رقم الهاتف من أي أحرف غير رقمية
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: cleanedNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $launchUri';
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product['title'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: widget.product['image'].isEmpty
                    ? Icon(Icons.image_not_supported,
                        size: 60, color: Colors.grey)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported,
                                size: 60, color: Colors.grey);
                          },
                        ),
                      ),
              ),
              SizedBox(height: 20),

              // عنوان المنتج
              Text(
                widget.product['title'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // حالة المنتج
              Text(
                widget.product['state'],
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),

              // السعر
              Text(
                widget.product['price'],
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D7D97)),
              ),
              SizedBox(height: 20),

              // وصف المنتج
              Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.product['description'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // معلومات البائع
              Text(
                'Seller Information:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.product['userName'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // أزرار الاتصال
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.phone, color: Colors.white),
                      label: Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          _makePhoneCall(widget.product['phoneNumber']),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.chat, color: Colors.white),
                      label: Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF25D366),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          _openWhatsApp(widget.product['whatsappNumber']),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 75,
        width: 326,
        child: BottomNavigationBar(
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

  Widget _buildHomeIcon() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: Color(0xffCBC3D6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.home,
        color: Colors.white,
        size: 24.0,
      ),
    );
  }
}*/
/*import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedIndex = 0; // المتغير الذي يخزن الرقم المحدد في الشريط السفلي

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // التنقل بين الصفحات
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/community_chat');
        break;
      case 2:
        Navigator.pushNamed(context, '/moms_guide');
        break;
      case 3:
        Navigator.pushNamed(context, '/voice_recognition');
        break;
      case 4:
        Navigator.pushNamed(context, '/marketplace');
        break;
      case 5:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C6E0), // نفس اللون المستخدم في الكود السابق
      appBar: AppBar(
        backgroundColor:
            Color(0xFFD2C6E0), // نفس اللون المستخدم في الكود السابق
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 30, height: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.product['title'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.product['image'].isEmpty
                  ? Icon(Icons.image_not_supported, size: 100)
                  : Image.network(
                      widget.product['image'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported, size: 100);
                      },
                    ),
              SizedBox(height: 20),
              Text(
                widget.product['title'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Price: ${widget.product['price']}',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              SizedBox(height: 20),
              Text(
                'Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.product['description'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'State:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.product['state'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Phone Number:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.product['phoneNumber'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'WhatsApp Number:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.product['whatsappNumber'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'User Name:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.product['userName'],
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
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
          onTap: _onItemTapped,
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
*/
