import 'package:flutter/material.dart';
import 'package:garage/features/admin/admin_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://muyfwnkayewwdghkfmbm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im11eWZ3bmtheWV3d2RnaGtmbWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0MDYwNzksImV4cCI6MjA3Njk4MjA3OX0.XbIeVmfhumb0SQDD35URlOqYhlC0fHGNgFaUeG1YVZE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: FirebaseAuth.instance.currentUser == null ? AuthPage() : HomePageView(),
      home: AdminPage(),
    );
  }
}
