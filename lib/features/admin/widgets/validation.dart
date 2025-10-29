import 'package:image_picker/image_picker.dart';

class CarValidator {
  static String? validateAll({
    required String engine,
    required String speed,
    required String seats,
    required String model,
    required String price,
    required String? brand,
    required XFile? image,
  }) {
    if (engine.trim().isEmpty) return "Please enter the engine capacity";
    final engineValue = int.tryParse(engine.trim());
    if (engineValue == null || engineValue < 1200 || engineValue > 8000) {
      return "Engine must be between 1200 and 8000 cc";
    }

    if (speed.trim().isEmpty) return "Please enter the car speed";
    final speedValue = int.tryParse(speed.trim());
    if (speedValue == null || speedValue < 100 || speedValue > 600) {
      return "Speed must be between 100 and 600 km/h";
    }

    if (seats.trim().isEmpty) return "Please enter number of seats";
    final seatsValue = int.tryParse(seats.trim());
    if (seatsValue == null || seatsValue < 1 || seatsValue > 8) {
      return "Seats must be between 1 and 8";
    }

    if (model.trim().isEmpty) return "Please enter the car model";
    if (price.trim().isEmpty) return "Please enter the car price";
    if (brand == null) return "Please select a car brand";
    if (image == null) return "Please pick a car image";

    return null;
  }
}
