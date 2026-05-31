import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String googleMapsKey = dotenv.get(
    'GOOGLE_MAPS_API_KEY',
    fallback: 'Key Not Found',
  );

  // Gunakan IP yang terbukti jalan dari PatientProvider
  // static const String baseUrl = 'https://cg9hrzdk-5134.asse.devtunnels.ms/api';
  // static const String baseUrl = 'http://192.168.100.203:5134/api';
  //static const String baseUrl = 'http://10.219.9.31:5134/api';
  //static const String baseUrl = 'https://9r038pvg-5134.asse.devtunnels.ms/';
  static const String baseUrl = 'https://9r038pvg-5134.asse.devtunnels.ms/api/';

  // ID Faskes dummy untuk testing (nanti kita ganti dinamis saat fitur Login selesai)
  static const String defaultFaskesId = '65a0f259-fe09-4dd6-b241-461fa5423991';

  // TODO: ganti dengan ID super admin dari auth/session saat tersedia.
  static const String defaultSuperAdminId =
      'a2197255-1fba-43cb-8636-a333b1812e37';

  static const String dummyPatientId = "11111111-1111-1111-1111-111111111111";
}
