import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'faskes_location_detail_model.dart';
import 'faskes_location_summary_model.dart';

class Faskes {
  final String id;
  final String nama;
  final LatLng posisi;
  final String lokasi;
  final String status;
  final String tipe;
  final String? emergencyContact;
  final String? operatingHours;

  Faskes({
    required this.id,
    required this.nama,
    required this.posisi,
    required this.lokasi,
    required this.status,
    required this.tipe,
    this.emergencyContact,
    this.operatingHours,
  });

  factory Faskes.fromDetail(FaskesLocationDetailModel detail) {
    return Faskes(
      id: detail.id,
      nama: detail.name,
      posisi: LatLng(detail.latitude, detail.longitude),
      lokasi: detail.address,
      status: detail.operatingHours.isNotEmpty
          ? detail.operatingHours
          : 'Belum tersedia',
      tipe: detail.type,
      emergencyContact: detail.emergencyContact,
      operatingHours: detail.operatingHours,
    );
  }

  factory Faskes.fromMapItem(FaskesLocationSummaryModel item) {
    return Faskes(
      id: item.id,
      nama: item.name,
      posisi: LatLng(item.latitude, item.longitude),
      lokasi: item.address,
      status: item.operatingHours.isNotEmpty
          ? item.operatingHours
          : 'Belum tersedia',
      tipe: item.type,
      operatingHours: item.operatingHours,
    );
  }

  bool get isOpen {
    final normalizedStatus = status.toLowerCase();
    return normalizedStatus.contains('24 jam') ||
        normalizedStatus.contains('buka') ||
        normalizedStatus.contains('open');
  }
}

class FaskesWithDistance {
  final Faskes faskes;
  final double distance;

  FaskesWithDistance({required this.faskes, required this.distance});
}
