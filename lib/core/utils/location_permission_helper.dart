import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHelper {
  // Fungsi utama yang akan dipanggil saat pasien masuk ke Beranda
  static Future<void> checkAndRequestPermission(BuildContext context) async {
    // 1. Cek apakah izin "Allow all the time" sudah diberikan sebelumnya
    if (await Permission.locationAlways.isGranted) {
      return; // Jika sudah, hentikan fungsi. Aman!
    }

    // 2. Munculkan Pop-up Penjelasan (Aturan Wajib Google Play)
    if (!context.mounted) return;
    bool? proceed = await showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan mengetuk luar area
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on_rounded, color: Color(0xFF1060EF)),
            SizedBox(width: 8),
            Text("Izin Lokasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          "TBCare membutuhkan akses lokasi Anda sepanjang waktu (Allow all the time) "
          "meskipun aplikasi ditutup atau tidak digunakan.\n\n"
          "Ini berfungsi agar petugas kesehatan dapat memantau pergerakan rutin "
          "untuk memastikan pemulihan Anda berjalan optimal.\n\n"
          "Mohon pilih 'Izinkan sepanjang waktu' / 'Allow all the time' pada layar berikutnya.",
          style: TextStyle(height: 1.4, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Nanti Saja", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1060EF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Mengerti", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (proceed != true) return; // Jika pasien menolak, berhenti.

    // 3. Minta izin Foreground ("While using the app") terlebih dahulu
    var statusForeground = await Permission.locationWhenInUse.request();

    if (statusForeground.isGranted) {
      // 4. Jika diizinkan, baru minta izin Background ("Allow all the time")
      var statusBackground = await Permission.locationAlways.request();

      if (statusBackground.isDenied || statusBackground.isPermanentlyDenied) {
        // Jika ditolak lagi secara permanen, arahkan ke Pengaturan HP
        if (context.mounted) _showSettingsDialog(context);
      }
    } else if (statusForeground.isPermanentlyDenied) {
      if (context.mounted) _showSettingsDialog(context);
    }
  }

  // Pop-up jika pasien memblokir izin dan harus buka Pengaturan HP manual
  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Izin Diblokir", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "Fitur pemantauan memerlukan izin lokasi latar belakang. "
          "Silakan buka Pengaturan HP, masuk ke menu Izin (Permissions), "
          "dan ubah akses lokasi TBCare menjadi 'Allow all the time'.",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1060EF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              openAppSettings(); // Membuka pengaturan HP otomatis
              Navigator.pop(dialogContext);
            },
            child: const Text("Buka Pengaturan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}