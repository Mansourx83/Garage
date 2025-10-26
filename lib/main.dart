import 'package:flutter/material.dart';
import 'package:garage/core/constants/constants.dart';
import 'package:garage/features/admin/admin_page.dart';
import 'package:garage/features/home/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: apiUrl, anonKey: anonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: FirebaseAuth.instance.currentUser == null ? AuthPage() : HomePage(),
      home: HomePage(),
    );
  }
}
