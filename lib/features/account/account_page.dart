import 'package:flutter/material.dart';
import 'package:garage/core/components/custom_text.dart';

class AccountPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const AccountPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? 'Guest';
    final email = userData?['email'] ?? 'example@email.com';
    final avatar = userData?['avatar_url'] ??
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxWd_qyeMG-05UoSEmiNlEcKzWnIpoXdl_A&s";
    final location = userData?['location'] ?? 'Egypt';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("My Account", style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/car.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 50, backgroundImage: NetworkImage(avatar)),
                const SizedBox(height: 20),
                CustomText(
                  text: name,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                CustomText(
                  text: email,
                  fontSize: 16,
                  color: Colors.white70,
                ),
                const SizedBox(height: 10),
                CustomText(
                  text: location,
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
