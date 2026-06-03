import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/faskes_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/data/models/faskes_upsert_request.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/geocoding_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/faskes_map_picker_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/custom_button.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/widgets/faskes_form_kategori.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/widgets/faskes_form_field.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/widgets/faskes_form_location_field.dart';

class FaskesFormPage extends ConsumerStatefulWidget {
  final String pageTitle;
  final String actionLabel;
  final String? faskesId;
  final String initialKategori;
  final String initialNama;
  final LatLng? initialCoordinate;
  final String initialAlamat;
  final String initialTelepon;

  const FaskesFormPage({
    super.key,
    this.pageTitle = 'Tambah Faskes',
    this.actionLabel = 'Simpan Faskes',
    this.faskesId,
    this.initialKategori = 'Puskesmas',
    this.initialNama = '',
    this.initialCoordinate,
    this.initialAlamat = '',
    this.initialTelepon = '',
  });

  @override
  ConsumerState<FaskesFormPage> createState() => _FaskesFormPageState();
}

class _FaskesFormPageState extends ConsumerState<FaskesFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatLengkapController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    namaController.text = widget.initialNama;
    alamatLengkapController.text = widget.initialAlamat;
    teleponController.text = widget.initialTelepon;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(faskesFormControllerProvider.notifier)
          .initialize(
            selectedKategori: widget.initialKategori,
            selectedCoordinate: widget.initialCoordinate,
          );
    });
  }

  @override
  void dispose() {
    namaController.dispose();
    alamatLengkapController.dispose();
    teleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(faskesFormControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pageTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    FaskesFormKategori(
                      selectedKategori: formState.selectedKategori,
                      onSelect: (label) => ref
                          .read(faskesFormControllerProvider.notifier)
                          .setKategori(label),
                    ),
                    const SizedBox(height: 32),
                    FaskesFormField(
                      label: 'Nama Fasilitas Kesehatan',
                      hint: 'Masukkan nama resmi',
                      controller: namaController,
                    ),
                    const SizedBox(height: 20),
                    FaskesFormLocationField(
                      selectedCoordinate: formState.selectedCoordinate,
                      onTap: _pickLocation,
                    ),
                    const SizedBox(height: 20),
                    FaskesFormField(
                      label: 'Alamat Lengkap',
                      hint: 'Contoh: Jl. Keputih Sukolilo, Kec. Sukolilo',
                      controller: alamatLengkapController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    FaskesFormField(
                      label: 'Nomor Telepon Faskes',
                      hint: '(Kode Area) Nomor...',
                      controller: teleponController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  width: double.infinity,
                  label: _isSaving ? 'Menyimpan...' : widget.actionLabel,
                  icon: Icons.save,
                  onPressed: _isSaving ? null : _saveFaskes,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFaskes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedState = ref.read(faskesFormControllerProvider);
    final selectedCoordinate = selectedState.selectedCoordinate;

    if (selectedCoordinate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih titik lokasi terlebih dahulu.')),
      );
      return;
    }

    final request = FaskesUpsertRequest(
      name: namaController.text.trim(),
      type: selectedState.selectedKategori,
      latitude: selectedCoordinate.latitude,
      longitude: selectedCoordinate.longitude,
      address: alamatLengkapController.text.trim(),
      emergencyContact: teleponController.text.trim(),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final mutationController = ref.read(faskesMutationControllerProvider);

      if (widget.faskesId == null) {
        await mutationController.createFaskes(request);
      } else {
        await mutationController.updateFaskes(widget.faskesId!, request);
      }

      ref.invalidate(faskesManagementProvider);
      if (widget.faskesId != null) {
        ref.invalidate(faskesDetailProvider(widget.faskesId!));
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickLocation() async {
    final currentCoordinate = ref
        .read(faskesFormControllerProvider)
        .selectedCoordinate;

    final coordinate = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => FaskesMapPickerPage(
          initialCoordinate: currentCoordinate ?? widget.initialCoordinate,
        ),
      ),
    );

    if (coordinate == null) {
      return;
    }

    ref.read(faskesFormControllerProvider.notifier).setCoordinate(coordinate);

    try {
      setState(() {
        alamatLengkapController.text = 'Mengambil alamat otomatis...';
      });

      final alamatOtomatis = await ref
          .read(geocodingControllerProvider)
          .convertCoordinateToAddress(
            coordinate.latitude,
            coordinate.longitude,
          );

      if (!mounted) return;

      setState(() {
        alamatLengkapController.text = alamatOtomatis;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        alamatLengkapController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan alamat otomatis: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
