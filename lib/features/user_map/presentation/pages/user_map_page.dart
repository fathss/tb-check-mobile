import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:tbcheck_app/core/widgets/custom_search_field.dart';
import 'package:tbcheck_app/features/user_map/data/models/faskes_model.dart';
import 'package:tbcheck_app/features/user_map/presentation/controllers/user_map_controller.dart';
import 'package:tbcheck_app/features/user_map/presentation/widgets/faskes_list_bottom_sheet.dart';
import 'package:tbcheck_app/features/user_map/presentation/widgets/filter_chip.dart';

class UserMapPage extends ConsumerStatefulWidget {
  const UserMapPage({super.key});

  @override
  ConsumerState<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends ConsumerState<UserMapPage> {
  Position? _currentPosition;
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  final TextEditingController _searchController = TextEditingController();
  final int maxFaskesReachRadius = 10000;

  String _selectedTipe = 'Semua';
  final List<String> _tipeOptions = ['Semua', 'Puskesmas', 'Rumah Sakit'];

  final String googleApiKey = AppConstants.googleMapsKey;

  late GlobalKey<State<FaskesListBottomSheet>> _faskesSheetKey;

  @override
  void initState() {
    super.initState();
    _faskesSheetKey = GlobalKey<State<FaskesListBottomSheet>>();
    _checkPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _focusOnFaskes(Faskes faskes) async {
    final target = faskes.posisi;

    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 17),
        ),
      );
    }
  }

  List<Faskes> _filterFaskes(List<Faskes> allFaskes) {
    if (_currentPosition == null) {
      return const [];
    }

    final query = _searchController.text.trim().toLowerCase();

    return allFaskes.where((faskes) {
      if (_selectedTipe != 'Semua' && faskes.tipe != _selectedTipe) {
        return false;
      }

      if (query.isNotEmpty) {
        final name = faskes.nama.toLowerCase();
        final lokasi = faskes.lokasi.toLowerCase();
        if (!name.contains(query) && !lokasi.contains(query)) {
          return false;
        }
      }

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        faskes.posisi.latitude,
        faskes.posisi.longitude,
      );

      return distance <= maxFaskesReachRadius;
    }).toList();
  }

  List<FaskesWithDistance> _buildFaskesWithDistance(List<Faskes> faskesList) {
    if (_currentPosition == null) {
      return const [];
    }

    final list = faskesList
        .map(
          (faskes) => FaskesWithDistance(
            faskes: faskes,
            distance: Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              faskes.posisi.latitude,
              faskes.posisi.longitude,
            ),
          ),
        )
        .toList();

    list.sort((a, b) => a.distance.compareTo(b.distance));
    return list;
  }

  Set<Marker> _buildMarkers(List<FaskesWithDistance> faskesWithDistance) {
    return faskesWithDistance
        .map(
          (entry) => Marker(
            markerId: MarkerId(entry.faskes.id),
            position: entry.faskes.posisi,
            infoWindow: InfoWindow(title: entry.faskes.nama),
            onTap: () async {
              final state = _faskesSheetKey.currentState;
              if (state != null) {
                (state as dynamic).selectFaskes(entry.faskes);
              }
            },
          ),
        )
        .toSet();
  }

  void _clearPolylines() {
    setState(() {
      _polylines.clear();
    });
  }

  Future<void> getPolylines(LatLng destination) async {
    final polylinePoints = PolylinePoints(apiKey: googleApiKey);

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      final polylineCoordinates = <LatLng>[];

      for (final point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('asli_rute'),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          ),
        );
      });

      if (_mapController != null) {
        final userPos = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        final bounds = LatLngBounds(
          southwest: LatLng(
            math.min(userPos.latitude, destination.latitude),
            math.min(userPos.longitude, destination.longitude),
          ),
          northeast: LatLng(
            math.max(userPos.latitude, destination.latitude),
            math.max(userPos.longitude, destination.longitude),
          ),
        );

        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } else {
      // ignore: avoid_print
      print('Gagal mengambil rute: ${result.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final faskesAsync = ref.watch(userMapProvider);
    final allFaskes = faskesAsync.hasValue
        ? faskesAsync.value!
        : const <Faskes>[];
    final filteredFaskes = _filterFaskes(allFaskes);
    final faskesWithDistance = _buildFaskesWithDistance(filteredFaskes);
    final markers = _buildMarkers(faskesWithDistance);

    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15,
                  ),
                  markers: markers,
                  polylines: _polylines,
                  onTap: (_) {
                    setState(() {
                      _polylines.clear();
                    });
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  right: 8.0,
                  bottom: 100.0,
                  child: FloatingActionButton.small(
                    heroTag: 'current_pos_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    onPressed: () async {
                      if (_currentPosition == null || _mapController == null) {
                        return;
                      }
                      final target = LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      );
                      await _mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: target, zoom: 16),
                        ),
                      );
                    },
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 40.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: CustomSearchField(
                          controller: _searchController,
                          hintText: 'Cari Puskesmas atau RSUD...',
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      UserMapFilterChips(
                        options: _tipeOptions,
                        selectedValue: _selectedTipe,
                        onSelected: (tipe) {
                          setState(() {
                            _selectedTipe = tipe;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (faskesAsync.isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withOpacity(0.04),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  ),
                if (faskesAsync.hasError)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 140,
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gagal memuat faskes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              faskesAsync.error.toString().replaceFirst(
                                'Exception: ',
                                '',
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    ref.invalidate(userMapProvider),
                                child: const Text('Coba lagi'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                FaskesListBottomSheet(
                  key: _faskesSheetKey,
                  faskesWithDistance: faskesWithDistance,
                  onFaskesTap: (faskes) => _focusOnFaskes(faskes),
                  onRouteRequested: (faskes) => getPolylines(faskes.posisi),
                  onClose: _clearPolylines,
                  isLoading: faskesAsync.isLoading && allFaskes.isEmpty,
                  errorMessage: faskesAsync.hasError && allFaskes.isEmpty
                      ? faskesAsync.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        )
                      : null,
                ),
              ],
            ),
    );
  }
}
