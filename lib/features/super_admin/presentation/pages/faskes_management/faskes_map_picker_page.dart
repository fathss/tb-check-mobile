import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/custom_button.dart';

class FaskesMapPickerPage extends StatefulWidget {
  final LatLng? initialCoordinate;

  const FaskesMapPickerPage({super.key, this.initialCoordinate});

  @override
  State<FaskesMapPickerPage> createState() => _FaskesMapPickerPageState();
}

class _FaskesMapPickerPageState extends State<FaskesMapPickerPage> {
  static const LatLng _defaultPosition = LatLng(-7.2575, 112.7521);

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialCoordinate;
  }

  @override
  Widget build(BuildContext context) {
    final cameraTarget = _selectedLocation ?? _defaultPosition;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Faskes'),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              child: const Text(
                'PILIH',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: cameraTarget,
              zoom: 14,
            ),
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
          ),
          Positioned(
            bottom: 80.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomButton(
                  label: 'Simpan Koordinat',
                  onPressed: _selectedLocation == null
                      ? null
                      : () {
                          Navigator.pop(context, _selectedLocation);
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
