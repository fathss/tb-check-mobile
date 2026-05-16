import 'package:google_maps_flutter/google_maps_flutter.dart';

class Faskes {
  final String nama;
  final LatLng posisi;
  final String lokasi;
  final String status;
  final String tipe; // "Puskesmas" | "Rumah Sakit"

  Faskes({
    required this.nama,
    required this.posisi,
    required this.lokasi,
    required this.status,
    required this.tipe,
  });
}

class FaskesWithDistance {
  final Faskes faskes;
  final double distance;

  FaskesWithDistance({required this.faskes, required this.distance});
}

List<Faskes> daftarFaskesMockup = [
  Faskes(
    nama: "RS Mockup A",
    posisi: LatLng(-7.27343428113023, 112.79410458937798),
    lokasi: "Surabaya Pusat",
    status: "24 Jam",
    tipe: "Rumah Sakit",
  ),
  Faskes(
    nama: "Klinik Dummy B",
    posisi: LatLng(-7.267033914055989, 112.75798996191043),
    lokasi: "Surabaya Timur",
    status: "Buka",
    tipe: "Puskesmas",
  ),
  Faskes(
    nama: "Puskesmas Mentari",
    posisi: LatLng(-7.280033914055989, 112.76798996191043),
    lokasi: "Surabaya Barat",
    status: "24 Jam",
    tipe: "Puskesmas",
  ),
  Faskes(
    nama: "RSUD Soetomo",
    posisi: LatLng(-7.260033914055989, 112.73798996191043),
    lokasi: "Surabaya Selatan",
    status: "Buka",
    tipe: "Rumah Sakit",
  ),
  Faskes(
    nama: "RS Islam Surabaya",
    posisi: LatLng(-7.255412, 112.752301),
    lokasi: "Surabaya Utara",
    status: "24 Jam",
    tipe: "Rumah Sakit",
  ),
  Faskes(
    nama: "Klinik Sehat Sejahtera",
    posisi: LatLng(-7.291045, 112.771832),
    lokasi: "Surabaya Selatan",
    status: "Buka",
    tipe: "Puskesmas",
  ),
  Faskes(
    nama: "Puskesmas Wonokromo",
    posisi: LatLng(-7.298762, 112.733541),
    lokasi: "Wonokromo",
    status: "Buka",
    tipe: "Puskesmas",
  ),
  Faskes(
    nama: "RS Siloam Surabaya",
    posisi: LatLng(-7.263189, 112.801457),
    lokasi: "Surabaya Timur",
    status: "24 Jam",
    tipe: "Rumah Sakit",
  ),
  Faskes(
    nama: "Klinik Husada Medika",
    posisi: LatLng(-7.245678, 112.718923),
    lokasi: "Surabaya Barat",
    status: "Buka",
    tipe: "Puskesmas",
  ),
];
