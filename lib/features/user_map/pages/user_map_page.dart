import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:tbcheck_app/core/widgets/custom_search_field.dart';
import 'package:tbcheck_app/features/user_map/models/faskes_model.dart';
import 'package:tbcheck_app/features/user_map/widgets/bottom_sheet.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key});

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  Position? _currentPosition;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<FaskesWithDistance> _faskesWithDistance = [];
  final TextEditingController _searchController = TextEditingController();
  final int maxFaskesReachRadius = 10000; // in meters

  String googleApiKey = AppConstants.googleMapsKey;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1. Cek Izin & Ambil Lokasi Perangkat
  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _loadMarkers(); // Tampilkan faskes setelah lokasi user didapat
    });
  }

  // 2. Filter Faskes & Buat Marker
  void _loadMarkers() {
    // initialize with full (no search) — reuse _applySearch
    _applySearch('');
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

    // Intentionally not calling `_getPolylineRoute` here to avoid
    // automatically drawing a route when a marker or list item is tapped.
    // The `_getPolylineRoute` function remains available for future use.
  }

  // Apply search filter and rebuild markers & list
  void _applySearch(String query) {
    if (_currentPosition == null) return;

    final q = query.trim().toLowerCase();

    _markers.clear();
    _faskesWithDistance.clear();

    for (var faskes in daftarFaskesMockup) {
      // filter by query if provided
      if (q.isNotEmpty) {
        final name = faskes.nama.toLowerCase();
        final lokasi = faskes.lokasi.toLowerCase();
        if (!name.contains(q) && !lokasi.contains(q)) continue;
      }

      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        faskes.posisi.latitude,
        faskes.posisi.longitude,
      );

      if (distance <= maxFaskesReachRadius) {
        _markers.add(
          Marker(
            markerId: MarkerId(faskes.nama),
            position: faskes.posisi,
            infoWindow: InfoWindow(title: faskes.nama),
            onTap: () {
              _focusOnFaskes(faskes);
            },
          ),
        );

        _faskesWithDistance.add(
          FaskesWithDistance(faskes: faskes, distance: distance),
        );
      }
    }

    // Sort by distance
    _faskesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {});
  }

  void _getPolylineRoute(LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: googleApiKey);

    // Meminta data rute dari Google Directions API
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving, // Mode berkendara
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];

      // Mengubah hasil titik-titik dari Google menjadi LatLng Flutter
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.clear(); // Bersihkan rute lama jika ada
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("asli_rute"),
            color: Colors.blue,
            points: polylineCoordinates, // Titik-titik yang mengikuti jalan
            width: 5,
          ),
        );
      });
    } else {
      print("Gagal mengambil rute: ${result.errorMessage}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onTap: (LatLng pos) {
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
                // Current position button (placed above bottom sheet)
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
                      if (_currentPosition == null || _mapController == null)
                        return;
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

                // Search Bar Overlay
                Positioned(
                  top: 40.0,
                  left: 20.0,
                  right: 20.0,
                  child: CustomSearchField(
                    controller: _searchController,
                    hintText: 'Cari Puskesmas atau RSUD...',
                    onChanged: (value) => _applySearch(value),
                  ),
                ),

                UserMapBottomSheet(
                  faskesWithDistance: _faskesWithDistance,
                  onFaskesTap: (faskes) => _focusOnFaskes(faskes),
                ),
              ],
            ),
    );
  }
}
