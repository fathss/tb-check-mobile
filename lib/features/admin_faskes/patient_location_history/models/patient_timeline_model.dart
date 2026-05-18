import 'package:flutter/material.dart';

class PatientTimelineModel {
  final DateTime tanggal;
  final String waktu;
  final String lokasi;
  final double lat;
  final double lng;

  const PatientTimelineModel({
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    required this.lat,
    required this.lng,
  });
}

List<PatientTimelineModel> mockPatientTimelineData = [
  // 16 Mei
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 16),
    waktu: '08:30',
    lokasi: 'Klinik Utama Sehat',
    lat: -7.250445,
    lng: 112.768845,
  ),
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 16),
    waktu: '11:15',
    lokasi: 'Laboratorium Prodia Surabaya',
    lat: -7.265123,
    lng: 112.742311,
  ),
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 16),
    waktu: '14:00',
    lokasi: 'Apotek Kimia Farma',
    lat: -7.271220,
    lng: 112.750100,
  ),

  // 17 Mei
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 17),
    waktu: '09:00',
    lokasi: 'Rumah Sakit Siloam (Poli Jantung)',
    lat: -7.282341,
    lng: 112.744123,
  ),
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 17),
    waktu: '13:30',
    lokasi: 'Radiologi RS Siloam',
    lat: -7.282341,
    lng: 112.744123,
  ),
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 17),
    waktu: '16:45',
    lokasi: 'Fisioterapi Delta',
    lat: -7.291102,
    lng: 112.759942,
  ),

  // 18 Mei
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 18),
    waktu: '07:00',
    lokasi: 'Poli Rawat Jalan RSUD Dr. Soetomo',
    lat: -7.268845,
    lng: 112.758234,
  ),
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 18),
    waktu: '10:30',
    lokasi: 'Pusat Rehabilitasi Medik',
    lat: -7.270112,
    lng: 112.761001,
  ),
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 18),
    waktu: '12:00',
    lokasi: 'Apotek RSUD Dr. Soetomo',
    lat: -7.268845,
    lng: 112.758234,
  ),
  PatientTimelineModel(
    tanggal: DateTime(2026, 5, 18),
    waktu: '15:30',
    lokasi: 'Klinik Evaluasi Pasca-Tindakan',
    lat: -7.255900,
    lng: 112.771200,
  ),
];
