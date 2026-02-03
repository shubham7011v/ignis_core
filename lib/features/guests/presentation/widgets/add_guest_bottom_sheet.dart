import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';

class AddGuestBottomSheet extends StatefulWidget {
  final Function(String name, String phone) onAdd;

  const AddGuestBottomSheet({super.key, required this.onAdd});

  @override
  State<AddGuestBottomSheet> createState() => _AddGuestBottomSheetState();
}

class _AddGuestBottomSheetState extends State<AddGuestBottomSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: IgnisTheme.deepMaroon,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADD NEW GUEST',
            style: GoogleFonts.cinzel(
              color: IgnisTheme.goldAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField('FULL NAME', _nameController, Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(
            'PHONE NUMBER',
            _phoneController,
            Icons.phone_android_outlined,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty) {
                  widget.onAdd(_nameController.text, _phoneController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: IgnisTheme.actionRed,
                shape: const StadiumBorder(),
              ),
              child: Text(
                'ADD GUEST',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: IgnisTheme.goldAccent.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: IgnisTheme.goldAccent),
            ),
          ),
        ),
      ],
    );
  }
}
