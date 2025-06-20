import 'package:flutter/material.dart';
import 'package:motherhood_app/screens/CommunityChatScreen.dart';
import 'package:motherhood_app/screens/CongratulationsScreen.dart';
import 'package:motherhood_app/screens/CreateScreen.dart';
import 'package:motherhood_app/screens/EditprofileScreen.dart';
import 'package:motherhood_app/screens/MarketplaceScreen.dart';
import 'package:motherhood_app/screens/MomsGuideScreen.dart';
import 'package:motherhood_app/screens/MyProductsScreen.dart';
import 'package:motherhood_app/screens/ProfileScreen.dart';
import 'package:motherhood_app/screens/VerificationCodeScreen.dart';
import 'package:motherhood_app/screens/VoiceRecognitionScreen.dart';
import 'package:motherhood_app/screens/forget_password_screen.dart';
import 'package:motherhood_app/screens/home_screen.dart';
import 'package:motherhood_app/screens/login_screen.dart';
import 'package:motherhood_app/screens/sign_up_screen.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  //
  //
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // تحديد صفحة البداية
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forget_password': (context) => ForgetPasswordScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(
            // token: 'https://localhost:7054/api/Account/register',
            ),
        '/community_chat': (context) => CommunityChatScreen(
            /*apiUrl: "https://localhost:7054/api/Messages"*/),
        '/moms_guide': (context) => MomsGuideScreen(),
        '/voice_recognition': (context) => VoiceRecognitionScreen(),
        '/marketplace': (context) => MarketplaceScreen(),
        '/create': (context) => CreateScreen(),
        '/my_products': (context) => MyProductsScreen(),
        '/editProfile': (context) => EditProfileScreen(),
        '/verification-code': (context) => VerificationCodeScreen(
              email: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/congratulations': (context) => const CongratulationsScreen(),

        /*'/market': (context) => const MarketScreen(),
        '/add_product': (context) => const AddProductScreen(),*/
      },
    );
  }
}
