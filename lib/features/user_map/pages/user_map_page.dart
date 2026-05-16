import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:tbcheck_app/core/widgets/custom_search_field.dart';
import 'package:tbcheck_app/features/user_map/models/faskes_model.dart';
import 'package:tbcheck_app/features/user_map/widgets/filter_chip.dart';
import 'package:tbcheck_app/features/user_map/widgets/faskes_list_bottom_sheet.dart';

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
  final int maxFaskesReachRadius = 10000;

  String _selectedTipe = 'Semua';
  final List<String> _tipeOptions = ['Semua', 'Puskesmas', 'Rumah Sakit'];

  String googleApiKey = AppConstants.googleMapsKey;

  /// Key to access FaskesListBottomSheet state
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

    Position position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _currentPosition = position;
      _loadMarkers();
    });
  }

  void _loadMarkers() {
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
  }

  void _applySearch(String query) {
    if (_currentPosition == null) return;

    final q = query.trim().toLowerCase();

    _markers.clear();
    _faskesWithDistance.clear();

    for (var faskes in daftarFaskesMockup) {
      // Filter by tipe
      if (_selectedTipe != 'Semua' && faskes.tipe != _selectedTipe) continue;

      // Filter by query
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
            onTap: () async {
              // Show the detail bottom sheet for this faskes
              final state = _faskesSheetKey.currentState;
              if (state != null) {
                // Call selectFaskes using dynamic dispatch
                (state as dynamic).selectFaskes(faskes);
              }
            },
          ),
        );

        _faskesWithDistance.add(
          FaskesWithDistance(faskes: faskes, distance: distance),
        );
      }
    }

    _faskesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {});
  }

  void _clearPolylines() {
    setState(() {
      _polylines.clear();
    });
  }

  Future<void> getPolylines(LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: googleApiKey);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
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
      List<LatLng> polylineCoordinates = [];

      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("asli_rute"),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          ),
        );
      });

      // Animate camera to show both markers
      if (_mapController != null) {
        LatLng userPos = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        LatLngBounds bounds = LatLngBounds(
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

                // Current position button
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

                // Search Bar + Filter Chips Overlay
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
                          onChanged: (value) => _applySearch(value),
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
                          _applySearch(_searchController.text);
                        },
                      ),
                    ],
                  ),
                ),

                FaskesListBottomSheet(
                  key: _faskesSheetKey,
                  faskesWithDistance: _faskesWithDistance,
                  onFaskesTap: (faskes) => _focusOnFaskes(faskes),
                  onRouteRequested: (faskes) => getPolylines(faskes.posisi),
                  onClose: _clearPolylines,
                ),
              ],
            ),
    );
  }
}
