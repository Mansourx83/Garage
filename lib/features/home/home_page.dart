import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> cars = [];

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
    fetchCars(brand: 'All');
  }

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// الخلفية + البلور
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/home.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          /// المحتوى
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxWd_qyeMG-05UoSEmiNlEcKzWnIpoXdl_A&s",
                        ),
                      ),
                      const CustomText(
                        text: "Egypt , Banha",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      const Icon(
                        CupertinoIcons.circle_grid_3x3,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Welcome
                  Row(
                    children: const [
                      CustomText(
                        text: "Hello, ",
                        fontSize: 32,
                        color: Colors.white70,
                      ),
                      CustomText(
                        text: "Mansour",
                        fontSize: 32,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const CustomText(
                    text: "Choose your Ideal Car",
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),

                  const SizedBox(height: 20),

                  /// Brands Filter
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
                              color: isSelected
                                  ? Colors.white.withOpacity(0.95)
                                  : Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.white.withOpacity(0.18),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                CustomText(
                                  text: brand,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                if (isSelected) const SizedBox(width: 6),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.blueAccent,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Cars Grid
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
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
                                      builder: (_) => CarDetails(carData: car),
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
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
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
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
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: car['model'] ?? '',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white
                                                        .withOpacity(0.95),
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius: 3,
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                      ),
                                                    ],
                                                  ),
                                                  CustomText(
                                                    text: car['brand'] ?? '',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueAccent,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .arrow_circle_right_rounded,
                                                        color:
                                                            Colors.blueAccent,
                                                        size: 22,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
