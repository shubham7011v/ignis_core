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
  final List<XFile> _cardImages = [];
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

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
                          'Upload Information',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Main Instruction / Tip
                        _buildMainTip(palette),
                        const SizedBox(height: 32),

                        // Card Gallery Section
                        _buildLabel(
                          palette,
                          'Wedding Card / Details Photo',
                          Icons.picture_as_pdf,
                        ),
                        const SizedBox(height: 12),
                        _buildCardImageGallery(palette),

                        const SizedBox(height: 32),

                        // Photo Gallery Section (Couple Photos)
                        _buildLabel(
                          palette,
                          'Couple Photos (Optional)',
                          Icons.collections,
                        ),
                        const SizedBox(height: 12),
                        _buildPhotoGallery(palette),

                        const SizedBox(height: 48),
                        _buildHelperText(palette),
                      ],
                    ),
                  ),
                ),
              ),

              _buildNextButton(palette, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainTip(AppColorPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_circle, color: palette.accent, size: 28),
              const SizedBox(width: 12),
              Text(
                'EXPERT TIP',
                style: TextStyle(
                  color: palette.accent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'If no card is printed yet, simply write your wedding details on paper with a pen, click a photo, and upload it here.',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 15,
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(AppColorPalette palette, String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: palette.accent),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: palette.accent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.2,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildCardImageGallery(AppColorPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cardImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _cardImages.length) {
                return _buildAddButton(palette, 'Upload Card', () async {
                  final images = await _picker.pickMultiImage();
                  if (images.isNotEmpty) {
                    setState(() => _cardImages.addAll(images));
                  }
                });
              }
              return _buildPhotoThumbnail(palette, index, isCard: true);
            },
          ),
        ),
        if (_cardImages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              '* Marriage card or written note photo is required',
              style: TextStyle(color: palette.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoGallery(AppColorPalette palette) {
    return Container(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return _buildAddButton(palette, 'Add Photo', () async {
              final images = await _picker.pickMultiImage();
              if (images.isNotEmpty) {
                setState(() => _selectedImages.addAll(images));
              }
            });
          }
          return _buildPhotoThumbnail(palette, index);
        },
      ),
    );
  }

  Widget _buildAddButton(
    AppColorPalette palette,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.divider, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: palette.accent, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(
    AppColorPalette palette,
    int index, {
    bool isCard = false,
  }) {
    final list = isCard ? _cardImages : _selectedImages;
    return Stack(
      children: [
        Container(
          width: 120,
          height: 140,
          margin: const EdgeInsets.only(right: 12, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(File(list[index].path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 0,
          child: GestureDetector(
            onTap: () => setState(() => list.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelperText(AppColorPalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 18, color: palette.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Our studio team will manually transcribe the details from your uploaded photos to craft the video.',
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(AppColorPalette palette, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _isUploading || _cardImages.isEmpty
              ? null
              : () async {
                  setState(() => _isUploading = true);
                  final photosLink = await _uploadAllImages();

                  final details = WeddingDetails(
                    photosLink: photosLink,
                    inputType: 'card',
                  );

                  if (context.mounted) {
                    context.read<InvitationBloc>().add(DetailsUpdated(details));
                    setState(() => _isUploading = false);
                    Navigator.pushNamed(context, '/preview');
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: palette.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          child: _isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Review Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward),
                  ],
                ),
        ),
      ),
    );
  }

  Future<String?> _uploadAllImages() async {
    try {
      final String sessionId = const Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref();

      for (int i = 0; i < _cardImages.length; i++) {
        await storageRef
            .child("orders/$sessionId/card_$i.jpg")
            .putFile(File(_cardImages[i].path));
      }

      for (int i = 0; i < _selectedImages.length; i++) {
        await storageRef
            .child("orders/$sessionId/photo_$i.jpg")
            .putFile(File(_selectedImages[i].path));
      }

      return sessionId;
    } catch (e) {
      debugPrint("Upload failed: $e");
      return null;
    }
  }
}
