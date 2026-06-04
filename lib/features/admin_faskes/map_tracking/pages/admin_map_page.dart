import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../patients/providers/patient_provider.dart';
import '../../patients/models/patient_model.dart';
import '../utils/marker_generator.dart';
import '../widgets/map_bottom_sheet.dart';
import 'user_map_detail_page.dart';
import 'package:geolocator/geolocator.dart';

class AdminMapPage extends StatefulWidget {
  const AdminMapPage({Key? key}) : super(key: key);

  @override
  State<AdminMapPage> createState() => _AdminMapPageState();
}

class _AdminMapPageState extends State<AdminMapPage> {
  GoogleMapController? _mapController;
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Set<Marker> _currentMarkers = {};
  String _lastDataHash = '';

  // Mencatat titik tumpuk mana yang sedang 'mekar/dikipas'
  String? _expandedClusterKey;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-7.250445, 112.768845),
    zoom: 12.5,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PatientProvider>().fetchPatients(),
    );
  }

  Future<void> _refreshMarkers(List<PatientModel> patients) async {
    Set<Marker> newMarkers = {};
    Map<String, List<PatientModel>> grouped = {};

    // Kelompokkan pasien di koordinat yang sama persis
    for (var p in patients) {
      String key = "${p.latitude}_${p.longitude}";
      grouped.putIfAbsent(key, () => []).add(p);
    }

    for (var entry in grouped.entries) {
      var group = entry.value;
      var centerPos = LatLng(group.first.latitude!, group.first.longitude!);

      if (group.length > 1) {
        // --- JIKA LEBIH DARI 1 ORANG (TERTUMPUK) ---

        if (_expandedClusterKey == entry.key) {
          // STATE 2: SEDANG MEKAR (FANNED OUT)
          int count = group.length;

          for (int i = 0; i < count; i++) {
            // 1. PERLEBAR SUDUT BENTANGAN (Agar tidak dempet)
            double totalSpan =
                (count - 1) * 45.0; // Jarak antar pin dilebarkan dari 35 ke 45
            if (totalSpan > 160.0)
              totalSpan = 160.0; // Maksimal mekar 160 derajat (hampir lurus)

            double startAngle = -totalSpan / 2;
            double step = totalSpan / (count - 1);
            double currentAngle = startAngle + (i * step);

            PatientModel p = group[i];
            String initial = p.fullName.isNotEmpty
                ? p.fullName[0].toUpperCase()
                : 'U';
            Color color = p.status.toLowerCase().contains('sembuh')
                ? Colors.green
                : (p.status.toLowerCase().contains('drop')
                      ? Colors.red
                      : const Color(0xFF1060EF));

            final icon = await MarkerGenerator.createFannedMarker(
              text: initial,
              color: color,
              angleDegrees: currentAngle,
              stemLength:
                  95.0, // 2. PANJANGKAN TANGKAI: Pin mekar lebih panjang agar menjauh dari pusat
            );

            newMarkers.add(
              Marker(
                markerId: MarkerId('${entry.key}_$i'),
                position: centerPos,
                anchor: const Offset(0.5, 1.0),
                icon: icon,
                // 3. PRIORITAS Z-INDEX: Memastikan yang di tengah/klik terakhir berada di paling atas lapisannya
                zIndex: (100 - (currentAngle.abs())).toDouble(),
                onTap: () => _showSinglePatientPopup(p),
              ),
            );
          }
        } else {
          // STATE 1: MENGUMPUL JADI SATU (MENAMPILKAN ANGKA)
          final icon = await MarkerGenerator.createFannedMarker(
            text: "${group.length}",
            color: Colors.orange.shade700,
            angleDegrees: 0,
            isClusterParent: true,
          );

          newMarkers.add(
            Marker(
              markerId: MarkerId(entry.key),
              position: centerPos,
              anchor: const Offset(0.5, 1.0),
              icon: icon,
              onTap: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(centerPos, 16.5),
                );
                setState(
                  () => _expandedClusterKey = entry.key,
                ); // Trigger mekar ke state 2
              },
            ),
          );
        }
      } else {
        // --- JIKA HANYA 1 ORANG (NORMAL) ---
        var p = group.first;
        String initial = p.fullName.isNotEmpty
            ? p.fullName[0].toUpperCase()
            : 'U';
        Color color = p.status.toLowerCase().contains('sembuh')
            ? Colors.green
            : (p.status.toLowerCase().contains('drop')
                  ? Colors.red
                  : const Color(0xFF1060EF));

        final icon = await MarkerGenerator.createFannedMarker(
          text: initial,
          color: color,
          angleDegrees: 0,
        );
        newMarkers.add(
          Marker(
            markerId: MarkerId(entry.key),
            position: centerPos,
            anchor: const Offset(0.5, 1.0),
            icon: icon,
            onTap: () => _showSinglePatientPopup(p),
          ),
        );
      }
    }

    if (mounted) setState(() => _currentMarkers = newMarkers);
  }

  void _showSinglePatientPopup(PatientModel patient) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(patient.latitude!, patient.longitude!)),
    );

    // Gunakan BottomSheet bawaan Flutter untuk menampilkan ringkasan mini
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient.address ?? 'Alamat tidak tertera',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    patient.status,
                    style: const TextStyle(
                      color: Color(0xFF1060EF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1060EF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup popup mini
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserMapDetailPage(patient: patient),
                    ),
                  ); // Buka detail penuh
                },
                child: const Text(
                  'Lihat Detail Pengguna',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PatientModel> _getFilteredPatients(List<PatientModel> allPatients) {
    return allPatients.where((patient) {
      if (patient.latitude == null || patient.latitude == 0.0) return false;
      final matchesSearch = patient.fullName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      if (_selectedFilter == 'Semua') return matchesSearch;
      if (_selectedFilter == 'Aktif')
        return patient.status.toLowerCase().contains('aktif') && matchesSearch;
      if (_selectedFilter == 'Drop-out')
        return patient.status.toLowerCase().contains('drop') && matchesSearch;
      if (_selectedFilter == 'Sembuh')
        return patient.status.toLowerCase().contains('sembuh') && matchesSearch;
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PatientProvider>(
        builder: (context, provider, child) {
          final filteredPatients = _getFilteredPatients(provider.patients);

          // Render jika data berubah ATAU ketika animasi mekar dipicu
          String currentHash =
              '${filteredPatients.length}_$_expandedClusterKey';
          if (_lastDataHash != currentHash) {
            _lastDataHash = currentHash;

            // SOLUSI: Jadwalkan eksekusi SETELAH frame selesai di-build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _refreshMarkers(filteredPatients);
              }
            });
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _currentMarkers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
                padding: const EdgeInsets.only(bottom: 240, top: 120),
                onTap: (_) {
                  if (_expandedClusterKey != null) {
                    setState(() => _expandedClusterKey = null);
                  }
                },
              ),

              // Search & Filter
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                              decoration: const InputDecoration(
                                hintText: 'Cari lokasi pasien...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          'Semua',
                          'Aktif',
                          'Drop-out',
                          'Sembuh',
                        ].map((label) => _buildFilterChip(label)).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Positioned(
                top: 155,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: "btnLoc",
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        // Munculkan tulisan loading kecil di bawah
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mencari lokasi Anda...'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        try {
                          // Ambil lokasi asli GPS HP Admin
                          Position position =
                              await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );

                          // Terbangkan kamera ke lokasi tersebut dengan zoom lebih dekat (15.0)
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(position.latitude, position.longitude),
                              15.0,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Gagal mendapatkan lokasi. Pastikan GPS menyala.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.small(
                      heroTag: "btnRef",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        provider.fetchPatients();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sinkronisasi data...')),
                        );
                      },
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF1060EF),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Sheet Daftar Semua Pasien (Import dari widget terpisah)
              MapBottomSheet(
                patients: filteredPatients,
                onPatientTap: (patient) => _showSinglePatientPopup(patient),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
            _expandedClusterKey = null; // Tutup kipasan saat ganti filter
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1060EF) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
