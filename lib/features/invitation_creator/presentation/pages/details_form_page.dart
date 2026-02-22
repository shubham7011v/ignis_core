import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
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
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  InvitationInputType _inputType = InvitationInputType.manual;
  final List<Map<String, String>> _events = [];

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
    _inputType = state.details.inputType;
    _events.addAll(state.details.events);
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

                        // Input Mode Toggle
                        _buildInputModeToggle(palette),
                        const SizedBox(height: 32),

                        // Common Fields
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

                        if (_inputType == InvitationInputType.manual) ...[
                          _buildLabel(
                            palette,
                            'Event Program (Order of Events)',
                            Icons.auto_stories,
                          ),
                          _buildEventProgramBuilder(palette),
                          const SizedBox(height: 32),
                        ],

                        // Photo Gallery Section
                        _buildLabel(
                          palette,
                          _inputType == InvitationInputType.card
                              ? 'Upload Wedding Card Images'
                              : 'Wedding Photos (Optional)',
                          _inputType == InvitationInputType.card
                              ? Icons.upload_file
                              : Icons.collections,
                        ),
                        if (_inputType == InvitationInputType.card)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Please upload photos of both sides of your wedding card. Our designers will transcribe the details.',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        _buildPhotoGallery(palette),

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

  Widget _buildInputModeToggle(AppColorPalette palette) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: SegmentedButton<InvitationInputType>(
        segments: const [
          ButtonSegment(
            value: InvitationInputType.manual,
            label: Text('Manual Form'),
            icon: Icon(Icons.edit_note),
          ),
          ButtonSegment(
            value: InvitationInputType.card,
            label: Text('Card Upload'),
            icon: Icon(Icons.style),
          ),
        ],
        selected: {_inputType},
        onSelectionChanged: (Set<InvitationInputType> newSelection) {
          setState(() {
            _inputType = newSelection.first;
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.accent.withValues(alpha: 0.1);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.accent;
            }
            return palette.textSecondary;
          }),
          side: const WidgetStatePropertyAll(BorderSide.none),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        showSelectedIcon: false,
      ),
    );
  }

  Widget _buildEventProgramBuilder(AppColorPalette palette) {
    return Column(
      children: [
        ...List.generate(_events.length, (index) {
          final event = _events[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: event['title'],
                    onChanged: (val) => event['title'] = val,
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Event (e.g. Sangeet)',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: palette.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: event['time'],
                    onChanged: (val) => event['time'] = val,
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Time (e.g. 7 PM)',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _events.removeAt(index)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _events.add({'title': '', 'time': ''});
            });
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Event Item'),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.accent,
            side: BorderSide(color: palette.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
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
          onPressed: _isUploading
              ? null
              : () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null) {
                    setState(() => _isUploading = true);

                    String? photosLink;
                    if (_selectedImages.isNotEmpty) {
                      photosLink = await _uploadImages();
                    }

                    final details = WeddingDetails(
                      brideName: _brideNameController.text.trim(),
                      groomName: _groomNameController.text.trim(),
                      weddingDate: _selectedDate!,
                      venue: _venueController.text.trim(),
                      photosLink: photosLink,
                      inputType: _inputType,
                      events: _events,
                    );

                    if (context.mounted) {
                      context.read<InvitationBloc>().add(
                        DetailsUpdated(details),
                      );
                      setState(() => _isUploading = false);
                      Navigator.pushNamed(context, '/preview');
                    }
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
          child: _isUploading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
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

  Widget _buildPhotoGallery(AppColorPalette palette) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return _buildAddPhotoButton(palette);
          }
          return _buildPhotoThumbnail(palette, index);
        },
      ),
    );
  }

  Widget _buildAddPhotoButton(AppColorPalette palette) {
    if (_selectedImages.length >= 5) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.divider, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: palette.accent, size: 32),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(color: palette.textTertiary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(AppColorPalette palette, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 12, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(_selectedImages[index].path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 0,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImages.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 5) {
          _selectedImages.removeRange(5, _selectedImages.length);
        }
      });
    }
  }

  Future<String?> _uploadImages() async {
    try {
      final String sessionId = const Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref();

      // We will upload to a folder and return the folder path
      // The backend will use this path to show the photos
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = File(_selectedImages[i].path);
        final photoRef = storageRef.child("orders/$sessionId/photo_$i.jpg");
        await photoRef.putFile(file);
      }

      // Return a professional-looking Firebase Console link or just the folder path
      // For now, we'll return the sessionId which the backend uses to build the path.
      return sessionId;
    } catch (e) {
      debugPrint("Upload failed: $e");
      return null;
    }
  }
}
