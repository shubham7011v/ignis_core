import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class DetailsFormPage extends StatefulWidget {
  const DetailsFormPage({super.key});

  @override
  State<DetailsFormPage> createState() => _DetailsFormPageState();
}

class _DetailsFormPageState extends State<DetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _brideNameController = TextEditingController();
  final _groomNameController = TextEditingController();
  final _cityController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(
    BuildContext context,
    AppColorPalette palette,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: palette.primary,
              onPrimary: Colors.white,
              surface: palette.surface,
              onSurface: palette.textPrimary,
            ),
            dialogTheme: DialogThemeData(backgroundColor: palette.surface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPalette(AppThemeMode.royal);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          'Wedding Details',
          style: TextStyle(color: palette.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      body: Column(
        children: [
          // Progress Bar (Step 3 of 5 -> 60%)
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: palette.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 3 of 5',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter Details',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter the auspicious details for the couple.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields
                    _buildLabel(palette, "Bride's Name", Icons.female),
                    _buildTextField(
                      palette,
                      _brideNameController,
                      'e.g. Ananya Sharma',
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(palette, "Groom's Name", Icons.male),
                    _buildTextField(
                      palette,
                      _groomNameController,
                      'e.g. Rohan Mehta',
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(palette, "Wedding Date", Icons.calendar_today),
                    GestureDetector(
                      onTap: () => _selectDate(context, palette),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.divider),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'mm/dd/yyyy'
                                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? palette.textTertiary
                                    : palette.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.calendar_month,
                              color: palette.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(palette, "City", Icons.location_on),
                    _buildTextField(
                      palette,
                      _cityController,
                      'e.g. Udaipur, Rajasthan',
                    ),

                    const SizedBox(height: 32),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.warn.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: palette.warn.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: palette.warn,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'These names will appear in the main invitation video sequence. Ensure spelling matches government ID proofs if used for formal invites.',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Next Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null) {
                    Navigator.pushNamed(context, '/preview');
                  } else if (_selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a wedding date')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next Step',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(AppColorPalette palette, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: palette.warn),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: palette.warn,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    AppColorPalette palette,
    TextEditingController controller,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: palette.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: palette.textTertiary),
        filled: true,
        fillColor: palette.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
