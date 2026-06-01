import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' hide Provider; 
import 'package:tbcheck_app/features/medicine/providers/medicine_provider.dart';
import 'package:tbcheck_app/features/user_profile/presentation/controllers/user_profile_controller.dart';
// Wajib import auth_storage untuk mengambil ID dinamis
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // 1. Ubah variabel ID menjadi null dan dinamis
  String? currentUserId; 

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // 2. Fungsi untuk mengambil ID dari penyimpanan lokal
  Future<void> _loadUserId() async {
    final storage = ref.read(authStorageProvider);
    final id = await storage.getUserId();
    if (mounted) {
      setState(() {
        currentUserId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan layar kosong/loading jika ID belum didapat dari storage
    if (currentUserId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final homeSummaryAsync = ref.watch(homeSummaryProvider(currentUserId!));
    final medicineProvider = context.watch<MedicineProvider>();

    ref.listen(homeSummaryProvider(currentUserId!), (previous, next) {
      next.whenData((summary) {
        if (summary.patientId != null && medicineProvider.todaySchedules.isEmpty && !medicineProvider.isLoading) {
          context.read<MedicineProvider>().fetchTodaySchedule(summary.patientId!);
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- 1. HEADER & CARD DINAMIS ---
              homeSummaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                data: (summary) {
                  final String namaDepan = summary.fullName.split(" ").first;
                  final String inisial = summary.fullName.isNotEmpty ? summary.fullName[0].toUpperCase() : "A";
                  
                  // KONDISIONAL 1: Subtitle & Teks Progress (Pendekatan Harian)
                  final int persentase = (medicineProvider.progressPercentage * 100).toInt();
                  String sapaanSubtitle = "Waktunya Pulih";
                  
                  // Narasi diubah menjadi fokus harian (Mikro)
                  String teksProgress = "Kamu telah menyelesaikan $persentase% dari\njadwal obatmu hari ini. Terus semangat!";

                  if (summary.patientId == null) {
                    sapaanSubtitle = "Selamat Datang";
                    teksProgress = "Profil medismu belum terdaftar di Faskes.\nData pengobatan belum tersedia.";
                  } else if (summary.fase.toLowerCase().contains("selesai") || summary.fase.toLowerCase().contains("sembuh")) {
                    sapaanSubtitle = "Tetap Jaga Kesehatan";
                    teksProgress = "Luar biasa! Kamu telah menyelesaikan\nseluruh masa pengobatanmu.";
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFFE9F0FF),
                                child: Text(inisial, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1060EF))),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Halo, $namaDepan", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text(sapaanSubtitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300), color: Colors.white),
                            child: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 24),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1060EF), 
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: const Color(0xFF1060EF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                  child: Text(summary.fase, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)), 
                                ),
                                const SizedBox(height: 20),
                                Text(teksProgress, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 20),
                                // Menampilkan "X / Y Obat Hari Ini"
                                Text("${medicineProvider.dosisSelesai} / ${medicineProvider.totalDosis} Obat Hari Ini", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(value: medicineProvider.progressPercentage, minHeight: 10, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
                                ),
                              ],
                            ),
                          ),
                          Positioned(right: -20, bottom: -10, child: Icon(Icons.health_and_safety_rounded, size: 160, color: Colors.white.withOpacity(0.08))),
                        ],
                      ),
                    ],
                  );
                }
              ),

              const SizedBox(height: 32),
              const Text("Jadwal Hari ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),

              // --- 3. LIST JADWAL OBAT DINAMIS ---
              Expanded(
                child: homeSummaryAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                  data: (summary) {
                    
                    // KONDISIONAL 2: Belum Terdaftar
                    if (summary.patientId == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_information_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text("Profil Medis Belum Terdaftar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 8),
                            Text("Silakan hubungi Faskes terdekat\nuntuk pendaftaran pengobatanmu.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                      );
                    }
                    
                    if (medicineProvider.isLoading) return const Center(child: CircularProgressIndicator());
                    
                    // KONDISIONAL 3: Jadwal Kosong
                    if (medicineProvider.todaySchedules.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_note_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text("Belum Ada Jadwal Obat", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 8),
                            Text("Tambahkan obat melalui menu di bawah\nagar pengobatanmu terpantau.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                      );
                    }
                    
                    // KONDISIONAL 4: Cek apakah semua obat sudah diminum
                    bool isAllDone = medicineProvider.todaySchedules.every((s) => s.isDone);

                    return Column(
                      children: [
                        // Banner Apresiasi jika semua beres
                        if (isAllDone)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                            child: Row(
                              children: [
                                Icon(Icons.task_alt_rounded, color: Colors.green.shade600),
                                const SizedBox(width: 12),
                                Expanded(child: Text("Hebat! Semua jadwal obat hari ini sudah selesai diminum.", style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600))),
                              ],
                            ),
                          ),
                        
                        // List Obat
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: medicineProvider.todaySchedules.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final schedule = medicineProvider.todaySchedules[index];
                              return _buildMedicineItem(context: context, scheduleId: schedule.scheduleId, time: schedule.time, title: schedule.title, subtitle: schedule.subtitle, isDone: schedule.isDone, patientId: summary.patientId!);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineItem({required BuildContext context, required String scheduleId, required String time, required String title, required String subtitle, required bool isDone, required String patientId}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 75, child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87))),
              Container(height: 40, width: 1.5, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
              ),
              Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: isDone ? Colors.green.shade500 : Colors.grey.shade400, size: 28),
            ],
          ),
          
          if (!isDone) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1060EF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                onPressed: () async {
                  bool success = await context.read<MedicineProvider>().confirmConsume(scheduleId, patientId);
                  if (success) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil konfirmasi obat!'), backgroundColor: Colors.green));
                  }
                },
                child: const Text("Konfirmasi Minum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }
}