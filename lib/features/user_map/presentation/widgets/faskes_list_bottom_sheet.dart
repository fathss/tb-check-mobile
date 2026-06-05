import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/user_map/data/models/faskes_model.dart';
import 'package:tbcheck_app/features/user_map/presentation/widgets/faskes_card.dart';
import 'package:tbcheck_app/features/user_map/presentation/widgets/faskes_detail_bottom_sheet.dart';

// --- IMPORT DUA PACKAGE INI ---
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class FaskesListBottomSheet extends StatefulWidget {
  final List<FaskesWithDistance> faskesWithDistance;
  final Future<void> Function(Faskes faskes) onFaskesTap;
  final Future<void> Function(Faskes faskes) onRouteRequested;
  final VoidCallback onClose;
  final bool isLoading;
  final String? errorMessage;

  const FaskesListBottomSheet({
    super.key,
    required this.faskesWithDistance,
    required this.onFaskesTap,
    required this.onRouteRequested,
    required this.onClose,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<FaskesListBottomSheet> createState() => _FaskesListBottomSheetState();
}

class _FaskesListBottomSheetState extends State<FaskesListBottomSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final GlobalKey _detailSheetKey = GlobalKey();
  Faskes? _selectedFaskes;
  double? _selectedDistance;
  bool _isDetailOpen = false;
  double _detailInitialSize = 0.4;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _handleItemTap(Faskes faskes, double distance) async {
    setState(() {
      _selectedFaskes = faskes;
      _selectedDistance = distance;
      _isDetailOpen = true;
    });
    await widget.onFaskesTap(faskes);
  }

  void _handleDetailClose() {
    setState(() {
      _selectedFaskes = null;
      _selectedDistance = null;
      _isDetailOpen = false;
    });

    widget.onClose();
  }

  Future<void> selectFaskes(Faskes faskes) async {
    double? distance;
    for (var item in widget.faskesWithDistance) {
      if (item.faskes.id == faskes.id) {
        distance = item.distance;
        break;
      }
    }

    if (distance != null) {
      final wasOpen = _isDetailOpen;
      _detailInitialSize = 0.4;
      await _handleItemTap(faskes, distance);

      if (wasOpen) {
        final state = _detailSheetKey.currentState;
        if (state != null) {
          (state as dynamic).handleMarkerPressed(0.4);
        }
      }
    }
  }

  // --- FUNGSI UNTUK MENELEPON ---
  Future<void> _launchPhoneApp(String phoneNumber) async {
    // Bersihkan karakter selain angka dan + dari nomor telepon
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
        );
      }
    }
  }

  // --- FUNGSI UNTUK SHARE LOKASI ---
  void _shareFaskes(Faskes faskes) {
    // Menggunakan URL standar Google Maps Search
    final String mapsLink = "https://www.google.com/maps/search/?api=1&query=${faskes.posisi.latitude},${faskes.posisi.longitude}";
    final String phoneText = faskes.emergencyContact ?? "Tidak tersedia";
    final String shareText = "Puskesmas/RS Rujukan TB: *${faskes.nama}*\n\nAlamat: ${faskes.lokasi}\nTelepon: $phoneText\n\n📍 Buka di Maps: $mapsLink";
    
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDetailOpen && _selectedFaskes != null) {
      return FaskesDetailBottomSheet(
        key: _detailSheetKey,
        faskesName: _selectedFaskes!.nama,
        address: _selectedFaskes!.lokasi,
        distance: 'Berjarak ${_formatDistance(_selectedDistance!)} dari lokasimu',
        openingHours: _selectedFaskes!.status,
        isOpen: _selectedFaskes!.isOpen,
        initialSize: _detailInitialSize,
        onRoutePressed: () => widget.onRouteRequested(_selectedFaskes!),
        
        // --- LOGIKA TOMBOL TELEPON & SHARE ---
        onPhonePressed: () {
          final phone = _selectedFaskes!.emergencyContact;
          if (phone != null && phone.isNotEmpty && phone != "-") {
            _launchPhoneApp(phone);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nomor telepon faskes tidak tersedia')),
            );
          }
        },
        onSharePressed: () => _shareFaskes(_selectedFaskes!),
        // -------------------------------------
        
        onClose: _handleDetailClose,
      );
    }

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.35,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.1, 0.35, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: widget.isLoading
              ? SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16.0),
                          Text('Memuat faskes...'),
                        ],
                      ),
                    ),
                  ),
                )
              : widget.errorMessage != null
              ? SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          widget.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : widget.faskesWithDistance.isEmpty
              ? SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            width: 40.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Faskes di Sekitarmu',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Text(
                            'Tidak ada Faskes di sekitar Anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Center(
                        child: Container(
                          width: 40.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'Faskes di Sekitarmu',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: List.generate(
                          widget.faskesWithDistance.length,
                          (index) {
                            final faskesData = widget.faskesWithDistance[index];
                            final faskes = faskesData.faskes;
                            final distanceText = _formatDistance(
                              faskesData.distance,
                            );

                            return FaskesCard(
                              faskes: faskes,
                              distanceText: distanceText,
                              onTap: () {
                                _detailInitialSize = 0.4;
                                _handleItemTap(faskes, faskesData.distance);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ), // Penutup ListView
        ); // Penutup Container
      }, // Penutup builder
    ); // Penutup DraggableScrollableSheet
  }
}