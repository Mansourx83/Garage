import 'package:flutter/material.dart';
import 'package:garage/core/constants/constants.dart';
import 'package:garage/features/auth/login_page.dart';
import 'package:garage/features/home/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: apiUrl, anonKey: anonKey);
  debugPrint("Supabase initialized ✅");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: supabase.auth.currentSession == null
          ? const LoginPage()
          : const HomePage(),
    );
  }
}
