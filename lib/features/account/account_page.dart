import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:garage/core/components/custom_button.dart';
import 'package:garage/core/components/custom_text_field.dart';
import 'package:garage/core/components/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.isDarkMode = false});
  final bool isDarkMode;
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController nameController;
  late TextEditingController addressController;
  String? email;
  String? avatarUrl;

  bool isSaving = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    addressController = TextEditingController();
    loadUserData();
  }

  // 🟢 تحميل بيانات المستخدم
  Future<void> loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('users')
          .select('name, address, email, avatar_url')
          .eq('id', user.id)
          .single();

      setState(() {
        nameController.text = response['name'] ?? '';
        addressController.text = response['address'] ?? '';
        email = response['email'] ?? '';
        avatarUrl = response['avatar_url'];
        isLoading = false;
      });
    } catch (e) {
      showCustomSnackBar(context, '❌ Error loading user data');
      setState(() => isLoading = false);
    }
  }

  // 📸 اختيار صورة جديدة
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final file = File(picked.path);
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 🟢 رفع الصورة في bucket avatars
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            'users/$userId/$fileName',
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // 🟢 الحصول على رابط الصورة العام
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl('users/$userId/$fileName');

      setState(() => avatarUrl = publicUrl);

      showCustomSnackBar(
        context,
        '✅ Image uploaded successfully!',
        isError: false,
      );
    } catch (e) {
      print('❌ Upload Error: $e');
      showCustomSnackBar(context, '❌ Error uploading image');
    }
  }

  // 💾 حفظ التعديلات
  Future<void> saveChanges() async {
    try {
      setState(() => isSaving = true);
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase
          .from('users')
          .update({
            'name': nameController.text.trim(),
            'address': addressController.text.trim(),
            'avatar_url': avatarUrl,
          })
          .eq('id', user.id);

      showCustomSnackBar(
        context,
        ' Changes saved successfully!',
        isError: false,
      );
    } catch (e) {
      showCustomSnackBar(context, '❌ Failed to save changes!');
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = widget.isDarkMode
        ? Colors.redAccent
        : Colors.blueAccent;
    final Color textColor = Colors.white;
    final Color secondaryText = Colors.white70;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: widget.isDarkMode
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
              image: !widget.isDarkMode
                  ? DecorationImage(
                      image: AssetImage('assets/home.jpg'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.isDarkMode ? 3 : 6,
              sigmaY: widget.isDarkMode ? 3 : 6,
            ),
            child: Container(
              color: widget.isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.25),
            ),
          ),

          if (isLoading)
            Center(child: CircularProgressIndicator(color: mainColor))
          else
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      SizedBox(height: 10),
                      // 🖼️ الصورة الشخصية
                      GestureDetector(
                        onTap: pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl!)
                                  : const AssetImage('assets/avatar.png')
                                        as ImageProvider,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: mainColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🧑 الاسم
                      CustomTextField(
                        controller: nameController,
                        hint: "Name",
                        type: TextInputType.name,
                      ),

                      const SizedBox(height: 16),

                      // 📍 العنوان
                      CustomTextField(
                        controller: addressController,
                        hint: "Address",
                        type: TextInputType.streetAddress,
                      ),

                      const SizedBox(height: 16),

                      // 📧 الإيميل (عرض فقط)
                      CustomTextField(
                        controller: TextEditingController(text: email ?? ''),
                        hint: "Email (read-only)",
                        enable: false,
                        type: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 30),

                      // 🔘 زر الحفظ
                      CustomButton(
                        color: mainColor,
                        fontSize: 16,
                        text: isSaving ? 'Saving...' : 'Save Changes',
                        onTap: isSaving ? null : saveChanges,
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
}
