import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/core/components/custom_text.dart';

/// صفحة تفاصيل السيارة
class CarDetailsPage extends StatelessWidget {
  final Map<String, dynamic> car;

  const CarDetailsPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("${car['brand']} ${car['model']}"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                car['image_url'] ?? '',
                fit: BoxFit.contain,
                height: 250,
              ),
            ),
            const SizedBox(height: 20),
            CustomText(
              text: "Engine: ${car['engine'] ?? 'N/A'}",
              fontSize: 16,
              color: Colors.white,
            ),
            CustomText(
              text: "Speed: ${car['speed'] ?? 'N/A'}",
              fontSize: 16,
              color: Colors.white,
            ),
            CustomText(
              text: "Seats: ${car['seats'] ?? 'N/A'}",
              fontSize: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            CustomText(
              text: "Price: \$${car['price'] ?? 'N/A'}",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}