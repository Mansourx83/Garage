import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:garage/core/components/custom_text.dart';
import 'package:garage/core/components/custom_button.dart';

class CarDetails extends StatelessWidget {
  const CarDetails({
    super.key,
    required this.carData,
    required this.isDarkMode,
  });

  final Map carData;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    // 🎨 ألوان حسب الثيم
    final Color mainColor = isDarkMode ? Colors.redAccent : Colors.blueAccent;
    final Color textColor = Colors.white;
    final Color secondaryText = Colors.white70;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌆 الخلفية
          Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF0D0D0D),
                        Color(0xFF1C1C1C),
                        Color(0xFF2E2E2E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              image: !isDarkMode
                  ? DecorationImage(
                      image: NetworkImage(
                        carData['image_url'] ?? carData['image'] ?? '',
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),

          /// ✨ تأثير البلور أو الشادو حسب الثيم
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDarkMode ? 3 : 10,
              sigmaY: isDarkMode ? 3 : 10,
            ),
            child: Container(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.35),
            ),
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
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🚘 صورة العربية
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: isDarkMode
                            ? const LinearGradient(
                                colors: [Color(0xFF1C1C1C), Color(0xFF2C2C2C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: !isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : null,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
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
                        gradient: isDarkMode
                            ? const LinearGradient(
                                colors: [Color(0xFF1C1C1C), Color(0xFF2C2C2C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: !isDarkMode
                            ? Colors.white.withOpacity(0.15)
                            : null,
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
                                color: textColor,
                              ),
                              CustomText(
                                text: "\$${carData['price'] ?? 0}",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          CustomText(
                            text: "${carData['brand'] ?? 'Brand'}",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: mainColor,
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
                                textColor: textColor,
                                secondaryText: secondaryText,
                              ),
                              _infoTile(
                                icon: Icons.flash_on_rounded,
                                label: "Speed",
                                value: "${carData['speed'] ?? 'N/A'} ",
                                textColor: textColor,
                                secondaryText: secondaryText,
                              ),
                              _infoTile(
                                icon: Icons.event_seat_rounded,
                                label: "Seats",
                                value: "${carData['seats'] ?? 'N/A'}",
                                textColor: textColor,
                                secondaryText: secondaryText,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// 📝 وصف إضافي
                          if (carData['description'] != null)
                            CustomText(
                              text: carData['description'],
                              fontSize: 15,
                              color: secondaryText,
                              fontWeight: FontWeight.w400,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔘 زر الحجز
                    Center(
                      child: CustomButton(
                        text: "Book Now",
                        fontSize: 17,
                        width: double.infinity,
                        color: mainColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("🚗 Booking confirmed!"),
                              backgroundColor: mainColor,
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

  /// 🔧 Widget لعرض معلومة السيارة
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color secondaryText,
  }) {
    return Column(
      children: [
        Icon(icon, color: secondaryText, size: 24),
        const SizedBox(height: 6),
        CustomText(text: label, fontSize: 13, color: secondaryText),
        CustomText(
          text: value,
          fontSize: 15,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
