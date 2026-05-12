import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String googleMapsKey = dotenv.get(
    'GOOGLE_MAPS_API_KEY',
    fallback: 'Key Not Found',
  );
}
