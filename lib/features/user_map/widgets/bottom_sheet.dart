import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/user_map/models/faskes_model.dart';
import 'package:tbcheck_app/features/user_map/widgets/faskes_card.dart';

class UserMapBottomSheet extends StatefulWidget {
  final List<FaskesWithDistance> faskesWithDistance;
  final Future<void> Function(Faskes faskes) onFaskesTap;

  const UserMapBottomSheet({
    super.key,
    required this.faskesWithDistance,
    required this.onFaskesTap,
  });

  @override
  State<UserMapBottomSheet> createState() => _UserMapBottomSheetState();
}

class _UserMapBottomSheetState extends State<UserMapBottomSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

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

  Future<void> _handleItemTap(Faskes faskes) async {
    await widget.onFaskesTap(faskes);

    try {
      await _sheetController.animateTo(
        0.12,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.12,
      minChildSize: 0.08,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: const [0.12, 0.8],
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
                              onTap: () => _handleItemTap(faskes),
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
