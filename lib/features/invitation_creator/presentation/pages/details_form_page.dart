import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../bloc/invitation_bloc.dart';
import '../bloc/invitation_event.dart';
import '../bloc/invitation_state.dart';
import '../../domain/entities/wedding_details.dart';

class DetailsFormPage extends StatefulWidget {
  const DetailsFormPage({super.key});

  @override
  State<DetailsFormPage> createState() => _DetailsFormPageState();
}

class _DetailsFormPageState extends State<DetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brideNameController;
  late TextEditingController _groomNameController;
  late TextEditingController _venueController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final state = context.read<InvitationBloc>().state;
    _brideNameController = TextEditingController(text: state.details.brideName);
    _groomNameController = TextEditingController(text: state.details.groomName);
    _venueController = TextEditingController(text: state.details.venue);
    _selectedDate = state.details.brideName.isEmpty
        ? null
        : state.details.weddingDate;
  }

  @override
  void dispose() {
    _brideNameController.dispose();
    _groomNameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    AppColorPalette palette,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: palette.accent, // Gold for date picker
              onPrimary: palette.background,
              surface: palette.surface,
              onSurface: palette.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
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
          style: TextStyle(
            color: palette.textPrimary,
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      body: BlocBuilder<InvitationBloc, InvitationState>(
        builder: (context, state) {
          return Column(
            children: [
              // Progress Bar (Step 2 of 3 -> ~66%)
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: palette.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
                minHeight: 4,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP 2 OF 3',
                          style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter Auspicious Details',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please provide the essential information for your cinematic invitation.',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields
                        _buildLabel(
                          palette,
                          'Bride\'s Name',
                          Icons.auto_awesome,
                        ),
                        _buildTextField(
                          palette,
                          _brideNameController,
                          'Ex: Ananya Sharma',
                        ),
                        const SizedBox(height: 24),

                        _buildLabel(palette, 'Groom\'s Name', Icons.favorite),
                        _buildTextField(
                          palette,
                          _groomNameController,
                          'Ex: Rohan Mehta',
                        ),
                        const SizedBox(height: 24),

                        _buildLabel(
                          palette,
                          'Wedding Date',
                          Icons.calendar_today,
                        ),
                        _buildDatePickerField(palette),
                        const SizedBox(height: 24),

                        _buildLabel(palette, 'Venue / City', Icons.location_on),
                        _buildTextField(
                          palette,
                          _venueController,
                          'Ex: The Palace, Udaipur',
                        ),

                        const SizedBox(height: 32),

                        // Info Box
                        _buildInfoBox(palette),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Next Button
              _buildNextButton(palette, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLabel(AppColorPalette palette, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: palette.accent),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: palette.accent,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1,
              fontFamily: 'Inter',
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
      style: TextStyle(color: palette.textPrimary, fontFamily: 'Inter'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: palette.textTertiary.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
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
          borderSide: BorderSide(color: palette.accent, width: 2),
        ),
        errorStyle: TextStyle(color: palette.error),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField(AppColorPalette palette) {
    return GestureDetector(
      onTap: () => _selectDate(context, palette),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.divider),
        ),
        child: Row(
          children: [
            Text(
              _selectedDate == null
                  ? 'Select Date'
                  : "${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}",
              style: TextStyle(
                color: _selectedDate == null
                    ? palette.textTertiary.withValues(alpha: 0.5)
                    : palette.textPrimary,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_month, color: palette.accent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(AppColorPalette palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: palette.accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These details will be used to generate your personalized video invitation. Double-check all spellings before proceeding.',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(AppColorPalette palette, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedDate != null) {
              final details = WeddingDetails(
                brideName: _brideNameController.text.trim(),
                groomName: _groomNameController.text.trim(),
                weddingDate: _selectedDate!,
                venue: _venueController.text.trim(),
              );

              context.read<InvitationBloc>().add(DetailsUpdated(details));
              Navigator.pushNamed(context, '/preview');
            } else if (_selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please select a wedding date'),
                  backgroundColor: palette.error,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: palette.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Review Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
