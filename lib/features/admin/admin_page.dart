import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/features/admin/widgets/validation.dart';
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

  // Controllers for form fields
  final _model = TextEditingController();
  final _price = TextEditingController();
  final _engine = TextEditingController();
  final _speed = TextEditingController();
  final _seats = TextEditingController();

  // Dropdown data
  final brands = ['Bmw', 'Lamborghini', 'Audi', 'Ford', 'Dodge', 'Mercedes'];
  String? selectedBrand;
  XFile? imageFile;
  bool isLoading = false;

  // ✅ Unified SnackBar for success/error messages
  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red.shade700 : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 📸 Pick image from gallery
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = picked);
  }

  // 🚀 Upload car to Supabase
  Future<void> _uploadCar() async {
    // Validate all fields
    final error = CarValidator.validateAll(
      engine: _engine.text,
      speed: _speed.text,
      seats: _seats.text,
      model: _model.text,
      price: _price.text,
      brand: selectedBrand,
      image: imageFile,
    );

    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      // Prepare formatted data
      final engine = "${_engine.text.trim()} cc";
      final speed = "${_speed.text.trim()} km/h";
      final price = "${_price.text.trim()} \$";

      // Upload image to Supabase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'cars/$fileName';
      await _supabase.storage
          .from('cars')
          .upload(storagePath, File(imageFile!.path));

      final imageUrl = _supabase.storage.from('cars').getPublicUrl(storagePath);

      // Insert data into Supabase table
      await _supabase.from('cars').insert({
        'brand': selectedBrand,
        'model': _model.text.trim(),
        'price': price,
        'engine': engine,
        'speed': speed,
        'seats': int.parse(_seats.text.trim()),
        'image_url': imageUrl,
      });

      _showSnack("Car uploaded successfully ✅");
      _clearFields();
    } catch (e) {
      _showSnack("Upload failed: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🧹 Clear all fields
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
          _buildBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Center(child: _buildFormContainer(isWide)),
          ),
        ],
      ),
    );
  }

  // 🎨 Page background with blur effect
  Widget _buildBackground() => Stack(
    fit: StackFit.expand,
    children: [
      const Image(image: AssetImage('assets/admin.jpg'), fit: BoxFit.cover),
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(color: Colors.black.withOpacity(0.25)),
      ),
    ],
  );

  // 🧱 Main form container
  Widget _buildFormContainer(bool isWide) => ClipRRect(
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

            _buildCarDetailsRow(),
            const SizedBox(height: 25),

            // Car model
            CustomTextField(
              controller: _model,
              hint: "Car Model",
              icon: Icons.directions_car,
              type: TextInputType.text,
            ),
            const SizedBox(height: 20),

            // Price field
            CustomTextField(
              controller: _price,
              hint: "Price",
              type: TextInputType.number,
              icon: Icons.attach_money,
              suffixText: "\$",
            ),
            const SizedBox(height: 20),

            _buildImagePicker(),
            const SizedBox(height: 25),

            // Dropdown for brand
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

            // Submit button
            CustomButton(
              onTap: _uploadCar,
              width: double.infinity,
              height: 52,
              radius: 12,
              text: '',
              fontSize: 16,
              child: Center(
                child: isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
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
  );

  // 🚗 Row for engine, speed, seats fields
  Widget _buildCarDetailsRow() => Row(
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
  );

  // 🖼️ Image picker widget
  Widget _buildImagePicker() => GestureDetector(
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
              child: Image.file(File(imageFile!.path), fit: BoxFit.cover),
            ),
    ),
  );
}
