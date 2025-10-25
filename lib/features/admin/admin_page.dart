import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage/core/components/custom_text_field.dart';
import 'package:garage/core/components/custom_button.dart';
import 'package:garage/features/admin/widgets/custom_dropdown.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  final _model = TextEditingController();
  final _price = TextEditingController();
  final _engine = TextEditingController();
  final _speed = TextEditingController();
  final _seats = TextEditingController();

  final brands = ['Bmw', 'Lamborghini', 'Audi', 'Ford', 'Dodge', 'Mercedes'];
  String? selectedBrand;
  XFile? imageFile;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = picked);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _uploadCar() async {
    // ✅ VALIDATIONS MANUAL
    if (_engine.text.trim().isEmpty) {
      _showError("Please enter the engine capacity");
      return;
    }
    final engineValue = int.tryParse(_engine.text.trim());
    if (engineValue == null || engineValue <= 0 || engineValue > 3000) {
      _showError("Engine must be between 1200 and 3000 cc");
      return;
    }

    if (_speed.text.trim().isEmpty) {
      _showError("Please enter the car speed");
      return;
    }
    final speedValue = int.tryParse(_speed.text.trim());
    if (speedValue == null || speedValue <= 0 || speedValue > 400) {
      _showError("Speed must be between 100 and 400 km/h");
      return;
    }

    if (_seats.text.trim().isEmpty) {
      _showError("Please enter number of seats");
      return;
    }
    final seatsValue = int.tryParse(_seats.text.trim());
    if (seatsValue == null || seatsValue < 2 || seatsValue > 8) {
      _showError("Seats must be between 2 and 8");
      return;
    }

    if (_model.text.trim().isEmpty) {
      _showError("Please enter the car model");
      return;
    }

    if (_price.text.trim().isEmpty) {
      _showError("Please enter the car price");
      return;
    }

    if (selectedBrand == null) {
      _showError("Please select a car brand");
      return;
    }

    if (imageFile == null) {
      _showError("Please pick a car image");
      return;
    }

    // ✅ بعد التأكد من كل حاجة
    setState(() => isLoading = true);

    try {
      final engine = "${_engine.text.trim()} cc";
      final speed = "${_speed.text.trim()} km/h";
      final price = "${_price.text.trim()} \$";

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'cars/$fileName';

      await _supabase.storage
          .from('cars')
          .upload(storagePath, File(imageFile!.path));
      final imageUrl = _supabase.storage.from('cars').getPublicUrl(storagePath);

      await _supabase.from('cars').insert({
        'brand': selectedBrand,
        'model': _model.text.trim(),
        'price': price,
        'engine': engine,
        'speed': speed,
        'seats': seatsValue,
        'image_url': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Car uploaded successfully ✅",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

      _clearFields();
    } catch (e) {
      _showError("Upload failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearFields() {
    _model.clear();
    _price.clear();
    _engine.clear();
    _speed.clear();
    _seats.clear();
    selectedBrand = null;
    imageFile = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/admin.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: isWide ? 700 : double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Add New Car",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ✅ أول 3 جنب بعض
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _engine,
                                hint: "Engine",
                                type: TextInputType.number,
                                suffixText: "cc",
                                maxLength: 4,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: CustomTextField(
                                controller: _speed,
                                hint: "Speed",
                                type: TextInputType.number,
                                suffixText: "km/h",
                                maxLength: 3,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: CustomTextField(
                                controller: _seats,
                                hint: "Seats",
                                type: TextInputType.number,
                                maxLength: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        CustomTextField(
                          controller: _model,
                          hint: "Car Model",
                          icon: Icons.directions_car,
                          type: TextInputType.text,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _price,
                          hint: "Price",
                          type: TextInputType.number,
                          icon: Icons.attach_money,
                          suffixText: "\$",
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white70),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: imageFile == null
                                ? const Center(
                                    child: Text(
                                      "Tap to pick image",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(imageFile!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        CustomDropdown(
                          value: selectedBrand,
                          hint: "Choose Brand",
                          valid: "Select brand",
                          items: brands
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(
                                    b,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedBrand = v),
                        ),
                        const SizedBox(height: 35),
                        CustomButton(
                          onTap: _uploadCar,
                          width: double.infinity,
                          height: 52,
                          radius: 12,
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
                                      fontSize: 17,
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
        ],
      ),
    );
  }
}
