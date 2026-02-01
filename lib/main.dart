import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'core/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GoApp());
}

class GoApp extends StatelessWidget {
  const GoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go Campaign',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      // هنا الـ HomeScreen هي اللي بتلعب دور المدير دلوقتي
      // وبتعرض (الرئيسية، طلباتي، وحساب الشركات)
      home: const HomeScreen(),
    );
  }
}
