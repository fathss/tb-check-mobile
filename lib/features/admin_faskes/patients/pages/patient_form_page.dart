import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/patient_provider.dart';
import 'dart:convert'; // Untuk json.decode
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Untuk mengambil API Key
import 'package:http/http.dart' as http; // Untuk request HTTP
import 'package:geolocator/geolocator.dart'; // Tambahan untuk menarik koordinat GPS asli

class PatientFormPage extends StatefulWidget {
  const PatientFormPage({Key? key}) : super(key: key);

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // Hanya ada 1 field alamat
  
  String _selectedTBType = 'Paru';
  DateTime _selectedDate = DateTime.now();

  // Variabel untuk menyimpan koordinat
  double? _latitude;
  double? _longitude;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; });
    }
  }

  // Fungsi untuk membuka halaman Map Picker
  Future<void> _openMapPicker() async {
    final initialLat = _latitude ?? -7.250445;
    final initialLng = _longitude ?? 112.768845;

    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(initialLat: initialLat, initialLng: initialLng),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _latitude = pickedLocation.latitude;
        _longitude = pickedLocation.longitude;
      });

      // PANGGIL FUNGSI REVERSE GEOCODING OTOMATIS DISINI
      _getAddressFromCoordinates(pickedLocation.latitude, pickedLocation.longitude);
    }
  }

  // FUNGSI BARU: MENGUBAH KOORDINAT MENJADI TEKS ALAMAT NYATA
  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    setState(() {
      _addressController.text = "Mencari alamat otomatis..."; 
    });

    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      
      // Jika API Key kosong, langsung beri tahu di console
      if (apiKey.isEmpty) {
        print("ERROR: API Key kosong! Cek file .env kamu.");
        setState(() { _addressController.text = ""; });
        _showSnackBar('API Key tidak ditemukan di .env', Colors.red);
        return;
      }

      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      // CEK APA KATA GOOGLE DI SINI:
      print("===== RESPON GOOGLE MAPS =====");
      print(response.body); 
      print("==============================");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final String formattedAddress = data['results'][0]['formatted_address'];
          setState(() {
            _addressController.text = formattedAddress; 
          });
        } else {
          setState(() { _addressController.text = ""; });
          // Ubah pesan error agar lebih spesifik
          _showSnackBar('Google Maps menolak: ${data['status']}', Colors.orange);
        }
      } else {
        setState(() { _addressController.text = ""; });
      }
    } catch (e) {
      print("ERROR JARINGAN: $e");
      setState(() { _addressController.text = ""; });
    }
  }

  // Fungsi helper untuk mempermudah pemanggilan SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _submitForm() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon tentukan titik lokasi di peta terlebih dahulu!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyimpan data...')),
      );

      final newPatientData = {
        "nik": _nikController.text,
        "fullName": _nameController.text,
        "tbType": _selectedTBType,
        "diagnosisDate": _selectedDate.toUtc().toIso8601String(),
        "latitude": _latitude, 
        "longitude": _longitude, 
        "address": _addressController.text,
        "faskesProfileId": "65a0f259-fe09-4dd6-b241-461fa5423991" // ID Asli NeonDB
      };

      final success = await context.read<PatientProvider>().createPatient(newPatientData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        context.read<PatientProvider>().fetchPatients();
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Pasien', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'NIK', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedTBType,
                decoration: InputDecoration(labelText: 'Tipe TBC', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Paru', 'Ekstra Paru'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedTBType = val!),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                title: const Text('Tanggal Diagnosis', style: TextStyle(fontSize: 14, color: Colors.grey)),
                subtitle: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontSize: 16, color: Colors.black)),
                trailing: const Icon(Icons.calendar_month_rounded, color: Colors.blue),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(labelText: 'Alamat Domisili', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // UI MAP PICKER
              const Text('Titik Koordinat (Geospasial)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    Icon(Icons.map_rounded, color: _latitude != null ? Colors.green : Colors.redAccent, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_latitude != null ? 'Titik Ditentukan' : 'Belum Ditentukan', style: TextStyle(fontWeight: FontWeight.bold, color: _latitude != null ? Colors.green : Colors.redAccent)),
                          const SizedBox(height: 4),
                          Text(_latitude != null ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}' : 'Geser pin pada peta.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _latitude != null ? Colors.orange : Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: _openMapPicker,
                      child: Text(_latitude != null ? 'Ubah Titik' : 'Pilih di Peta', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _submitForm,
                  child: const Text('Simpan Data Pasien', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// KELAS TAMBAHAN: MAP PICKER SCREEN
// ==========================================
class MapPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const MapPickerScreen({Key? key, required this.initialLat, required this.initialLng}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _currentPosition;
  GoogleMapController? _mapController; // Tambahkan controller untuk menggerakkan kamera

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.initialLat, widget.initialLng);

    // Cek apakah koordinat masih default (Pasien Baru). Jika ya, otomatis cari lokasi asli GPS!
    // (-7.250445 adalah default latitude yang kamu pasang di fungsi _openMapPicker)
    if (widget.initialLat == -7.250445) {
      _snapToCurrentLocation();
    }
  }

  // Fungsi untuk mengambil koordinat asli GPS HP dan memindahkan kamera
  Future<void> _snapToCurrentLocation() async {
    try {
      // Ambil posisi saat ini (Karena permission sudah beres, ini akan langsung jalan)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng myRealLocation = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentPosition = myRealLocation;
        });
      }

      // Animasi kamera terbang ke lokasi asli pengguna
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(myRealLocation, 17.5), // Zoom level 17.5 agar detail
        );
      }
    } catch (e) {
      print("Gagal mendapatkan lokasi GPS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geser Peta', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 16),
            onMapCreated: (controller) {
              _mapController = controller; // Simpan controller saat peta berhasil dirender
            },
            onCameraMove: (CameraPosition position) {
              _currentPosition = position.target; 
            },
            myLocationEnabled: true, // Akan memunculkan titik biru lokasi asli
            myLocationButtonEnabled: true, // Tombol bawaan Google Maps untuk kembali ke lokasi asli
            zoomControlsEnabled: false,
          ),
          
          // PIN STATIS DI TENGAH LAYAR
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35), 
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),
          
          // TOMBOL PILIH LOKASI (Di Bawah)
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1060EF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context, _currentPosition); 
                },
                child: const Text('Pilih Titik Ini', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}