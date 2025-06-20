import 'package:flutter/material.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF8D7D97), // لون الخلفية الرئيسي
          child: Column(
            children: [
              // زر الرجوع (اختياري)
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
              // الجزء الأبيض
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // الصورة
                      Image.asset(
                        'assets/images/Frame 2916.png', // الصورة المرفقة
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      // النص
                      const Text(
                        'Congratulations',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your password has been successfully\nchanged',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // زر Done
                      ElevatedButton(
                        onPressed: () {
                          // توجيه المستخدم إلى شاشة تسجيل الدخول
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login', // اسم الشاشة التي تريد التوجيه إليها
                            (route) =>
                                false, // إزالة كل الشاشات السابقة من المكدس
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D7D97),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          minimumSize:
                              const Size(double.infinity, 50), // لجعل الزر عريض
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
