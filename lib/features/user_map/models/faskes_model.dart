import 'package:google_maps_flutter/google_maps_flutter.dart';

class Faskes {
  final String nama;
  final LatLng posisi;
  final String lokasi; // Sub-district/location name
  final String status; // "Buka" or "24 Jam"

  Faskes({
    required this.nama,
    required this.posisi,
    required this.lokasi,
    required this.status,
  });
}

class FaskesWithDistance {
  final Faskes faskes;
  final double distance;

  FaskesWithDistance({required this.faskes, required this.distance});
}

// Contoh data mockup di sekitar Surabaya (Sesuaikan dengan lokasi Anda)
List<Faskes> daftarFaskesMockup = [
  Faskes(
    nama: "RS Mockup A",
    posisi: LatLng(-7.27343428113023, 112.79410458937798),
    lokasi: "Surabaya Pusat",
    status: "24 Jam",
  ),
  Faskes(
    nama: "Klinik Dummy B",
    posisi: LatLng(-7.267033914055989, 112.75798996191043),
    lokasi: "Surabaya Timur",
    status: "Buka",
  ),
  Faskes(
    nama: "Puskesmas Mentari",
    posisi: LatLng(-7.280033914055989, 112.76798996191043),
    lokasi: "Surabaya Barat",
    status: "24 Jam",
  ),
  Faskes(
    nama: "RSUD Soetomo",
    posisi: LatLng(-7.260033914055989, 112.73798996191043),
    lokasi: "Surabaya Selatan",
    status: "Buka",
  ),
];
