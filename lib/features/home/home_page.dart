import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/features/account/account_page.dart';
import 'package:garage/features/home/car_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage/core/components/custom_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  String? selectedBrand;
  bool isLoading = true;
  bool isDarkMode = false;

  List<Map<String, dynamic>> cars = [];

  // 🟢 بيانات المستخدم
  String userName = '';
  String userAddress = '';
  String userAvatarUrl = '';

  final List<String> brands = [
    'All',
    'Bmw',
    'Lamborghini',
    'Audi',
    'Ford',
    'Dodge',
    'Mercedes',
    'Jaguar',
  ];

  @override
  void initState() {
    super.initState();
    selectedBrand = 'All';
    fetchUserData();
    fetchCars(brand: 'All');
  }

  // 🟢 دالة جلب بيانات المستخدم
  Future<void> fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // ✅ جلب بيانات المستخدم الحالي من Supabase
      final response = await supabase
          .from('users')
          .select('name, address, avatar_url')
          .eq('id', user.id)
          .single();

      // ✅ بما إنك ضامن إن مفيش حاجة null، نحدث القيم مباشرة
      setState(() {
        userName = response['name'];
        userAddress = response['address'];
        userAvatarUrl = response['avatar_url'];
      });
    } catch (e) {
      debugPrint('❌ Error fetching user data: $e');
    }
  }

  // 🟢 دالة جلب العربيات
  Future<void> fetchCars({String? brand}) async {
    setState(() => isLoading = true);
    try {
      dynamic response;
      if (brand != null && brand != 'All') {
        response = await supabase.from('cars').select('*').eq('brand', brand);
      } else {
        response = await supabase.from('cars').select('*');
      }

      setState(() {
        cars = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching cars: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0D0D0D) : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🖼️ الخلفية حسب الثيم
          if (!isDarkMode)
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/home.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D0D0D),
                    Color(0xFF1C1C1C),
                    Color(0xFF2E2E2E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

          /// 💨 البلور أو الشادو
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDarkMode ? 3 : 6,
              sigmaY: isDarkMode ? 3 : 6,
            ),
            child: Container(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.25),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  /// 🔝 الـ Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🟢 صورة المستخدم من Database
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(userAvatarUrl),
                      ),
                      // 🟢 عنوان المستخدم من Database
                      CustomText(
                        text: userAddress,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),

                      /// ✅ الأيقونتين (الثيم + الحساب)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isDarkMode
                                  ? CupertinoIcons.moon_stars_fill
                                  : CupertinoIcons.sun_max_fill,
                              color: isDarkMode
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                isDarkMode = !isDarkMode;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.person_crop_circle_fill,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              // 👇 انتظر لما المستخدم يرجع من صفحة الـ Account
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AccountPage(isDarkMode: isDarkMode),
                                ),
                              );

                              // 👇 بعد الرجوع، أعد تحميل بيانات المستخدم
                              fetchUserData();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 👋 الترحيب
                  Row(
                    children: [
                      CustomText(
                        text: isDarkMode ? "Welcome back, " : "Hello, ",
                        fontSize: 30,
                        color: Colors.white70,
                      ),
                      // 🟢 اسم المستخدم من Database
                      CustomText(
                        text: userName,
                        fontSize: 30,
                        color: isDarkMode
                            ? Colors.redAccent
                            : Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  CustomText(
                    text: isDarkMode
                        ? "Choose your next ride 🔥"
                        : "Choose your Ideal Car",
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),

                  const SizedBox(height: 20),

                  /// 🚘 الفلاتر
                  SizedBox(
                    height: 46,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: brands.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final brand = brands[index];
                        final isSelected = brand == selectedBrand;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedBrand = brand);
                            fetchCars(brand: brand);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: isDarkMode && isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFFF0000),
                                        Color(0xFFB71C1C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: !isDarkMode
                                  ? (isSelected
                                        ? Colors.white.withOpacity(0.95)
                                        : Colors.white.withOpacity(0.12))
                                  : (isSelected
                                        ? Colors.redAccent.withOpacity(0.15)
                                        : Colors.white.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? (isDarkMode
                                          ? Colors.redAccent
                                          : Colors.blueAccent)
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                CustomText(
                                  text: "$brand ",
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? isDarkMode
                                            ? Colors.white
                                            : Colors.black
                                      : Colors.white70,
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: isDarkMode
                                        ? Colors.redAccent
                                        : Colors.blueAccent,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🚗 Grid
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: isDarkMode
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
                            ),
                          )
                        : cars.isEmpty
                        ? const Center(
                            child: CustomText(
                              text: "No cars found 🚗",
                              color: Colors.white,
                            ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(10),
                            itemCount: cars.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1 / 1.1,
                                ),
                            itemBuilder: (context, index) {
                              final car = cars[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarDetails(
                                      carData: car,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: isDarkMode
                                          ? [
                                              const Color(0xFF1C1C1C),
                                              const Color(0xFF2C2C2C),
                                            ]
                                          : [
                                              Colors.white.withOpacity(0.15),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (isDarkMode
                                                    ? Colors.redAccent
                                                    : Colors.black)
                                                .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          child: Image.network(
                                            car['image_url'] ?? '',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text: car['model'] ?? '',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            CustomText(
                                              text: car['brand'] ?? '',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Colors.redAccent
                                                  : Colors.blueAccent,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CustomText(
                                                  text:
                                                      "\$${car['price'] ?? 0}",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_circle_right_rounded,
                                                  color: isDarkMode
                                                      ? Colors.redAccent
                                                      : Colors.blueAccent,
                                                  size: 22,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
