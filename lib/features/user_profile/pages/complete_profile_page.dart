import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/form_widget.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  late final TextEditingController _nikController;
  late final TextEditingController _namaLengkapController;
  late final TextEditingController _tanggalLahirController;
  String? _selectedGender;

  static const List<String> _genderOptions = <String>['Laki-Laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController();
    _namaLengkapController = TextEditingController();
    _tanggalLahirController = TextEditingController();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaLengkapController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 34),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: FormWidget(
        titleText: 'Lengkapi Profil Kamu',
        fields: [
          const Padding(padding: EdgeInsets.only(bottom: 24.0)),
          _buildTextField(
            controller: _nikController,
            hintText: 'NIK',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            controller: _namaLengkapController,
            hintText: 'Nama Lengkap',
            prefixIcon: Icons.person_outline,
          ),
          _buildDateField(context),
          _buildGenderField(),
        ],
        buttonText: 'Simpan Profil',
        onButtonPressed: () {
          // TODO: Submit profile completion data.
        },
        footer: RichText(
          text: const TextSpan(
            text: ' ',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: _tanggalLahirController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: _inputDecoration(
          hintText: 'Tanggal Lahir',
          prefixIcon: Icons.calendar_today_outlined,
          suffixIcon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        items: _genderOptions
            .map(
              (gender) =>
                  DropdownMenuItem<String>(value: gender, child: Text(gender)),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
        decoration: _inputDecoration(
          hintText: 'Gender',
          prefixIcon: Icons.wc_outlined,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.tertiary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.tertiary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 120);
    final DateTime initialDate =
        _parseSelectedDate() ?? DateTime(now.year - 18);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: now,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _tanggalLahirController.text = _formatDate(pickedDate);
    });
  }

  DateTime? _parseSelectedDate() {
    final String value = _tanggalLahirController.text;
    if (value.isEmpty) {
      return null;
    }

    final List<String> parts = value.split('/');
    if (parts.length != 3) {
      return null;
    }

    final int? day = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
