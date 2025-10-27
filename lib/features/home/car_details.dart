import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:garage/core/components/custom_text.dart';
import 'package:garage/core/components/custom_button.dart'; // تأكد من المسار الصحيح للـ widget

class CarDetails extends StatelessWidget {
  const CarDetails({super.key, required this.carData});

  final Map carData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌆 خلفية الصورة (صورة العربية نفسها)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  carData['image_url'] ?? carData['image'] ?? '',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ✨ تأثير البلور (Glass Effect)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          /// 🔙 محتوى الصفحة
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔙 زر الرجوع
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🚘 صورة العربية (بوضوح أكثر فوق الخلفية)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        carData['image_url'] ?? carData['image'] ?? '',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 250,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// 💎 تفاصيل العربية
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🚘 الاسم و السعر
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: "${carData['model'] ?? 'Unknown Model'}",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              CustomText(
                                text: "\$${carData['price'] ?? 0}",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          CustomText(
                            text: "${carData['brand'] ?? 'Brand'}",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),

                          const SizedBox(height: 20),

                          /// ⚙️ المعلومات التقنية
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _infoTile(
                                icon: Icons.speed_rounded,
                                label: "Engine",
                                value: carData['engine'] ?? 'N/A',
                              ),
                              _infoTile(
                                icon: Icons.flash_on_rounded,
                                label: "Speed",
                                value: "${carData['speed'] ?? 'N/A'} ",
                              ),
                              _infoTile(
                                icon: Icons.event_seat_rounded,
                                label: "Seats",
                                value: "${carData['seats'] ?? 'N/A'}",
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// 📝 وصف أو تفاصيل إضافية
                          if (carData['description'] != null)
                            CustomText(
                              text: carData['description'],
                              fontSize: 15,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔘 زر “Book Now” باستخدام CustomButton
                    Center(
                      child: CustomButton(
                        text: "Book Now",
                        fontSize: 17,
                        width: double.infinity,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("🚗 Booking confirmed!"),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 Widget بسيط لعرض معلومة السيارة
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 6),
        CustomText(text: label, fontSize: 13, color: Colors.white70),
        CustomText(
          text: value,
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
