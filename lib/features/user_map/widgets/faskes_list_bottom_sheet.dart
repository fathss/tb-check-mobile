import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/user_map/models/faskes_model.dart';
import 'package:tbcheck_app/features/user_map/widgets/faskes_card.dart';
import 'package:tbcheck_app/features/user_map/widgets/faskes_detail_bottom_sheet.dart';

class FaskesListBottomSheet extends StatefulWidget {
  final List<FaskesWithDistance> faskesWithDistance;
  final Future<void> Function(Faskes faskes) onFaskesTap;
  final Future<void> Function(Faskes faskes) onRouteRequested;
  final VoidCallback onClose;

  const FaskesListBottomSheet({
    super.key,
    required this.faskesWithDistance,
    required this.onFaskesTap,
    required this.onRouteRequested,
    required this.onClose,
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

  /// Public method to select and show detail for a faskes
  Future<void> selectFaskes(Faskes faskes) async {
    // Find the distance for this faskes
    double? distance;
    for (var item in widget.faskesWithDistance) {
      if (item.faskes.nama == faskes.nama) {
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

  @override
  Widget build(BuildContext context) {
    if (_isDetailOpen && _selectedFaskes != null) {
      return FaskesDetailBottomSheet(
        key: _detailSheetKey,
        faskesName: _selectedFaskes!.nama,
        address: _selectedFaskes!.lokasi,
        distance:
            'Berjarak ${_formatDistance(_selectedDistance!)} dari lokasimu',
        openingHours: _selectedFaskes!.status,
        isOpen:
            _selectedFaskes!.status == '24 Jam' ||
            _selectedFaskes!.status == 'Buka',
        initialSize: _detailInitialSize,
        onRoutePressed: () => widget.onRouteRequested(_selectedFaskes!),
        onPhonePressed: () {},
        onSharePressed: () {},
        onClose: _handleDetailClose,
      );
    }

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.08, 0.8, 0.9],
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
          child: widget.faskesWithDistance.isEmpty
              ? Column(
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
                    Expanded(
                      child: Center(
                        child: Text(
                          'Tidak ada Faskes di sekitar Anda',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                ),
        );
      },
    );
  }
}
