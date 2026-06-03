import 'package:flutter/material.dart'; // Dibutuhkan untuk Color & Offset
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/utils/marker_generator.dart';
import 'package:tbcheck_app/features/user_map/data/models/faskes_model.dart';
import '../../data/repositories/user_map_repository.dart';

final userMapProvider = FutureProvider.autoDispose<List<Faskes>>((ref) async {
  final repository = ref.watch(userMapRepositoryProvider);
  return repository.getFaskesForMap();
});

final mapMarkersProvider = FutureProvider.autoDispose<Set<Marker>>((ref) async {
  final faskesAsync = ref.watch(userMapProvider);

  final List<Faskes> allFaskes = faskesAsync.value ?? [];

  Set<Marker> newMarkers = {};

  for (var faskes in allFaskes) {
    String initial = 'F';
    Color markerColor = AppColors.primary;

    final typeLower = faskes.tipe.toLowerCase();

    if (typeLower.contains('puskesmas')) {
      initial = 'P';
      markerColor = AppColors.magenta;
    } else if (typeLower.contains('rumah sakit') || typeLower.contains('rs')) {
      initial = 'RS';
      markerColor = AppColors.primary;
    }

    // Panggil fungsi gambar canvas
    final customIcon = await MarkerGenerator.createFannedMarker(
      text: initial,
      color: markerColor,
      angleDegrees: 0,
    );

    newMarkers.add(
      Marker(
        markerId: MarkerId(faskes.id),
        position: faskes.posisi,
        icon: customIcon,
        anchor: const Offset(0.5, 1.0),
      ),
    );
  }

  return newMarkers;
});
