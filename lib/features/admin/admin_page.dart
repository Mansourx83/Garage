import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/features/admin/widgets/validation.dart';
import 'package:garage/features/auth/login_page.dart';
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

  // Controllers
  final _model = TextEditingController();
  final _price = TextEditingController();
  final _engine = TextEditingController();
  final _speed = TextEditingController();
  final _seats = TextEditingController();

  final brands = [
    'Bmw',
    'Lamborghini',
    'Audi',
    'Ford',
    'Dodge',
    'McLaren',
    'Mercedes',
  ];
  String? selectedBrand;
  XFile? imageFile;
  bool isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // ← دي مهمة علشان تمسح كل الصفحات القديمة
    );
  }

  // ✅ SnackBar Helper
  void _showSnack(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: success ? Colors.green : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
    print("Upload error: $message");
  }

  // 📸 Pick image
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = picked);
  }

  // 🚀 Upload car
  Future<void> _uploadCar() async {
    // Validation check
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
      _showSnack(error, success: false);
      return;
    }

    // Start loading
    setState(() => isLoading = true);

    try {
      // Prepare formatted data
      final engine = "${_engine.text.trim()} cc";
      final speed = "${_speed.text.trim()} km/h";
      final price = double.parse(_price.text.trim());

      // Upload image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'cars/$fileName';
      await _supabase.storage.from('cars').upload(path, File(imageFile!.path));

      final imageUrl = _supabase.storage.from('cars').getPublicUrl(path);

      // Insert into table
      await _supabase.from('cars').insert({
        'brand': selectedBrand,
        'model': _model.text.trim(),
        'price': price,
        'engine': engine,
        'speed': speed,
        'seats': int.parse(_seats.text.trim()),
        'image_url': imageUrl,
      });

      // ✅ Show success SnackBar
      _showSnack("✅ Car uploaded successfully!");

      // Clear all fields
      _clearFields();
    } catch (e) {
      _showSnack("❌ Upload failed: $e", success: false);
    } finally {
      // Stop loading
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
          _buildBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Center(child: _buildFormContainer(isWide)),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Stack(
    fit: StackFit.expand,
    children: [
      const Image(image: AssetImage('assets/admin.jpg'), fit: BoxFit.cover),
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(color: Colors.black.withOpacity(0.40)),
      ),
    ],
  );

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
            const SizedBox(height: 20),

            _buildCarDetailsRow(),
            const SizedBox(height: 20),

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

            _buildImagePicker(),
            const SizedBox(height: 20),

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
            const SizedBox(height: 12),

            // ✅ Button with loading indicator
            CustomButton(
              onTap: isLoading ? null : _uploadCar,
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
            const SizedBox(height: 12),
            CustomButton(fontSize: 16, text: 'Logout', onTap: logout),
          ],
        ),
      ),
    ),
  );

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
