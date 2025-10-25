import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/core/components/custom_text_field.dart';
import 'package:garage/core/components/custom_button.dart';
import 'package:garage/features/admin/widgets/custom_dropdown.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _model = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _engine = TextEditingController();
  final TextEditingController _speed = TextEditingController();
  final TextEditingController _seats = TextEditingController();

  final List<String> brands = [
    'Bmw',
    'Lamborghini',
    'Audi',
    'Shelby',
    'Dodge',
    'Mercedes',
  ];

  String? selectedBrand;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// الخلفية (صورة أو لون)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/admin.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// تأثير Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          /// المحتوى الزجاجي
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 600,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Add New Car",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),

                          /// الصف الأول
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _engine,
                                  hint: "Car Engine",
                                  type: TextInputType.text,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomTextField(
                                  controller: _speed,
                                  hint: "Car Speed",
                                  type: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomTextField(
                                  controller: _seats,
                                  hint: "Seats",
                                  type: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _model,
                            hint: "Car Model",
                            type: TextInputType.text,
                            icon: Icons.directions_car,
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _price,
                            hint: "Car Price",
                            type: TextInputType.number,
                            icon: Icons.attach_money,
                          ),
                          const SizedBox(height: 20),

                          CustomDropdown(
                            value: selectedBrand,
                            valid: "Please select a brand",
                            hint: "Choose Car Brand",
                            items: brands
                                .map(
                                  (brand) => DropdownMenuItem(
                                    value: brand,
                                    child: Text(
                                      brand,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => selectedBrand = value);
                            },
                          ),
                          const SizedBox(height: 30),

                          /// زر الإضافة
                          CustomButton(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Add Car Button Pressed"),
                                ),
                              );
                            },
                            width: double.infinity,
                            height: 48,
                            radius: 10,
                            text: '',
                            fontSize: 16,
                            child: Center(
                              child: isLoading
                                  ? const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Add Car",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
