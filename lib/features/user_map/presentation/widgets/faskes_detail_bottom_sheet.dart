import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class FaskesDetailBottomSheet extends StatefulWidget {
  final String faskesName;
  final String address;
  final String distance;
  final String openingHours;
  final bool isOpen;
  final VoidCallback onRoutePressed;
  final VoidCallback onPhonePressed;
  final VoidCallback onSharePressed;
  final VoidCallback onClose;
  final double initialSize;

  const FaskesDetailBottomSheet({
    Key? key,
    required this.faskesName,
    required this.address,
    required this.distance,
    required this.openingHours,
    required this.isOpen,
    required this.onRoutePressed,
    required this.onPhonePressed,
    required this.onSharePressed,
    required this.onClose,
    this.initialSize = 0.4,
  }) : super(key: key);

  @override
  State<FaskesDetailBottomSheet> createState() =>
      _FaskesDetailBottomSheetState();
}

class _FaskesDetailBottomSheetState extends State<FaskesDetailBottomSheet> {
  late DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void handleMarkerPressed(double size) {
    _sheetController.animateTo(
      size,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleRoutePressed() {
    widget.onRoutePressed();
    // Keep the sheet expanded to 0.6 when route is displayed
    _sheetController.animateTo(
      0.08,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: widget.initialSize,
      minChildSize: 0.08,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.08, 0.4, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Drag Handle
              _buildDragHandle(),
              const SizedBox(height: 20.0),
              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildTitleSection(),
              ),
              const SizedBox(height: 24.0),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildActionButtons(),
              ),
              const SizedBox(height: 32.0),
              // Informasi Operasional Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildInformasiOperasional(),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.0,
        height: 4.0,
        margin: const EdgeInsets.only(top: 12.0),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Label and Close Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label
            Text(
              'PUSKESMAS RUJUKAN',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            // Close Button
            GestureDetector(
              onTap: widget.onClose,
              child: Icon(
                Icons.close,
                size: 24.0,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        // Name
        Text(
          widget.faskesName,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12.0),
        // Subtitle with distance
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16.0,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                widget.distance,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.directions_outlined,
          label: 'Rute',
          onPressed: _handleRoutePressed,
        ),
        _buildActionButton(
          icon: Icons.phone_outlined,
          label: 'Telepon',
          onPressed: widget.onPhonePressed,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onPressed: widget.onSharePressed,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24.0, color: AppColors.primary),
              const SizedBox(height: 8.0),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformasiOperasional() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Informasi Operasional',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16.0),
        // Info Card 1 - Alamat
        _buildInfoCard(
          icon: Icons.location_on_outlined,
          header: 'Alamat Lengkap',
          detail: widget.address,
        ),
        const SizedBox(height: 16.0),
        // Info Card 2 - Jam Operasional
        _buildInfoCard(
          icon: Icons.schedule_outlined,
          header: 'Jam Buka (Hari ini)',
          detail: widget.openingHours,
          statusBadge: widget.isOpen
              ? const _StatusBadge(
                  label: 'Sedang Buka',
                  backgroundColor: AppColors.successBg,
                  textColor: AppColors.success,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String header,
    required String detail,
    Widget? statusBadge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.third,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.cardStroke, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24.0, color: AppColors.primary),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      header,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (statusBadge != null) statusBadge,
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
