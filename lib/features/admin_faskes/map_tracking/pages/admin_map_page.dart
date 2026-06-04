import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../patients/providers/patient_provider.dart';
import '../../patients/models/patient_model.dart';
import '../../profile/providers/faskes_profile_provider.dart'; // Import Provider Faskes
import '../utils/marker_generator.dart';
import '../widgets/map_bottom_sheet.dart';
import 'user_map_detail_page.dart';
// Import geolocator dihapus karena kita pakai koordinat Faskes dari database

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
  String? _expandedClusterKey;

  static const CameraPosition _initialPosition = CameraPosition(target: LatLng(-7.250445, 112.768845), zoom: 12.5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
      context.read<FaskesProfileProvider>().fetchProfile(); // Tarik koordinat Faskes saat map dibuka
    });
  }

  Future<void> _refreshMarkers(List<PatientModel> patients, dynamic faskesProfile) async {
    Set<Marker> newMarkers = {};
    Map<String, List<PatientModel>> grouped = {};

    for (var p in patients) {
      String key = "${p.latitude}_${p.longitude}";
      grouped.putIfAbsent(key, () => []).add(p);
    }

    for (var entry in grouped.entries) {
      var group = entry.value;
      var centerPos = LatLng(group.first.latitude!, group.first.longitude!);

      if (group.length > 1) {
        if (_expandedClusterKey == entry.key) {
          int count = group.length;
          
          for (int i = 0; i < count; i++) {
            double totalSpan = (count - 1) * 45.0; 
            if (totalSpan > 160.0) totalSpan = 160.0; 
            
            double startAngle = -totalSpan / 2;
            double step = totalSpan / (count - 1);
            double currentAngle = startAngle + (i * step); 

            PatientModel p = group[i];
            String initial = p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : 'U';
            Color color = p.status.toLowerCase().contains('sembuh') ? Colors.green : (p.status.toLowerCase().contains('drop') ? Colors.red : const Color(0xFF1060EF));

            final icon = await MarkerGenerator.createFannedMarker(
              text: initial, color: color, angleDegrees: currentAngle, stemLength: 95.0, 
            );

            newMarkers.add(
              Marker(
                markerId: MarkerId('${entry.key}_$i'),
                position: centerPos, anchor: const Offset(0.5, 1.0), icon: icon,
                zIndex: (100 - (currentAngle.abs())).toDouble(), 
                onTap: () => _showSinglePatientPopup(p), 
              )
            );
          }
        } else {
          final icon = await MarkerGenerator.createFannedMarker(
            text: "${group.length}", color: Colors.orange.shade700, angleDegrees: 0, isClusterParent: true
          );
          
          newMarkers.add(
            Marker(
              markerId: MarkerId(entry.key), position: centerPos, anchor: const Offset(0.5, 1.0), icon: icon,
              onTap: () {
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(centerPos, 16.5));
                setState(() => _expandedClusterKey = entry.key); 
              },
            )
          );
        }
      } else {
        var p = group.first;
        String initial = p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : 'U';
        Color color = p.status.toLowerCase().contains('sembuh') ? Colors.green : (p.status.toLowerCase().contains('drop') ? Colors.red : const Color(0xFF1060EF));

        final icon = await MarkerGenerator.createFannedMarker(text: initial, color: color, angleDegrees: 0);
        newMarkers.add(
          Marker(
            markerId: MarkerId(entry.key), position: centerPos, anchor: const Offset(0.5, 1.0), icon: icon,
            onTap: () => _showSinglePatientPopup(p),
          )
        );
      }
    }

    // --- TAMBAHAN: MARKER KHUSUS UNTUK RUMAH SAKIT / FASKES ---
    if (faskesProfile != null && faskesProfile.latitude != null && faskesProfile.longitude != null) {
      final rsIcon = await MarkerGenerator.createFannedMarker(
        text: "RS", 
        color: Colors.teal.shade700, // Warna hijau toska khas medis
        angleDegrees: 0,
      );

      newMarkers.add(
        Marker(
          markerId: const MarkerId('faskes_utama'),
          position: LatLng(faskesProfile.latitude!, faskesProfile.longitude!),
          anchor: const Offset(0.5, 1.0),
          icon: rsIcon,
          zIndex: 999, // Pastikan pin RS selalu berada di lapisan teratas
          infoWindow: const InfoWindow(title: "Lokasi Anda (Faskes)"),
        )
      );
    }

    if (mounted) setState(() => _currentMarkers = newMarkers);
  }

  void _showSinglePatientPopup(PatientModel patient) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(patient.latitude!, patient.longitude!)));
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                      Text(patient.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(patient.address ?? 'Alamat tidak tertera', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE9F0FF), borderRadius: BorderRadius.circular(20)),
                  child: Text(patient.status, style: const TextStyle(color: Color(0xFF1060EF), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1060EF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (_) => UserMapDetailPage(patient: patient))); 
                },
                child: const Text('Lihat Detail Pengguna', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<PatientModel> _getFilteredPatients(List<PatientModel> allPatients) {
    return allPatients.where((patient) {
      if (patient.latitude == null || patient.latitude == 0.0) return false;
      final matchesSearch = patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'Semua') return matchesSearch;
      if (_selectedFilter == 'Aktif') return patient.status.toLowerCase().contains('aktif') && matchesSearch;
      if (_selectedFilter == 'Drop-out') return patient.status.toLowerCase().contains('drop') && matchesSearch;
      if (_selectedFilter == 'Sembuh') return patient.status.toLowerCase().contains('sembuh') && matchesSearch;
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PERUBAHAN: Gunakan Consumer2 untuk memantau Patient DAN Faskes sekaligus ---
      body: Consumer2<PatientProvider, FaskesProfileProvider>(
        builder: (context, patientProv, faskesProv, child) {
          final filteredPatients = _getFilteredPatients(patientProv.patients);
          final profile = faskesProv.profile;
          
          String currentHash = '${filteredPatients.length}_${_expandedClusterKey}_${profile?.latitude}';
          if (_lastDataHash != currentHash) {
            _lastDataHash = currentHash;
            _refreshMarkers(filteredPatients, profile); // Masukkan profil ke dalam generator marker
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _currentMarkers,
                // --- PERUBAHAN: Matikan pelacakan GPS fisik bawaan HP ---
                myLocationEnabled: false, 
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
                padding: const EdgeInsets.only(bottom: 240, top: 120),
                onTap: (_) {
                  if (_expandedClusterKey != null) setState(() => _expandedClusterKey = null);
                }, 
              ),

              Positioned(
                top: 50, left: 16, right: 16,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.maybePop(context))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: const InputDecoration(hintText: 'Cari lokasi pasien...', hintStyle: TextStyle(color: Colors.grey, fontSize: 14), prefixIcon: Icon(Icons.search, color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 11)),
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
                        children: ['Semua', 'Aktif', 'Drop-out', 'Sembuh'].map((label) => _buildFilterChip(label)).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 155, right: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: "btnLoc",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        // --- PERUBAHAN: Terbang ke kordinat Profil Faskes, bukan koordinat HP ---
                        if (profile != null && profile.latitude != null && profile.longitude != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kembali ke lokasi Faskes...'), duration: Duration(seconds: 1))
                          );
                          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
                            LatLng(profile.latitude!, profile.longitude!), 15.0
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lokasi Faskes belum diatur di Profil.'), backgroundColor: Colors.red)
                          );
                        }
                      },
                      child: const Icon(Icons.my_location_rounded, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.small(heroTag: "btnRef", backgroundColor: Colors.white, onPressed: () { patientProv.fetchPatients(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sinkronisasi data...'))); }, child: const Icon(Icons.refresh_rounded, color: Color(0xFF1060EF))),
                  ],
                ),
              ),

              MapBottomSheet(
                patients: filteredPatients,
                onPatientTap: (patient) => _showSinglePatientPopup(patient),
              )
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
            _expandedClusterKey = null; 
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF1060EF) : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200)),
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        ),
      ),
    );
  }
}