import 'package:flutter/material.dart';
import '../../data/models/admin_template.dart';
import '../bloc/admin_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminTemplateForm extends StatefulWidget {
  final AdminTemplate? template; // null for create
  const AdminTemplateForm({super.key, this.template});

  @override
  State<AdminTemplateForm> createState() => _AdminTemplateFormState();
}

class _AdminTemplateFormState extends State<AdminTemplateForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _thumbController;
  late TextEditingController _youtubeIdController;
  late TextEditingController _priceController;

  String _selectedCategory = 'Traditional';
  final List<String> _categories = ['Traditional', 'Modern', 'Minimal'];

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _thumbController = TextEditingController(text: t?.thumbnailUrl ?? '');
    _youtubeIdController = TextEditingController(text: t?.youtubeId ?? '');
    _priceController = TextEditingController(
      text: t?.price.toString() ?? '0.0',
    );

    // Set initial category if valid, otherwise default
    if (t?.category.isNotEmpty == true && _categories.contains(t!.category)) {
      _selectedCategory = t.category;
    } else {
      _selectedCategory = _categories.first;
    }

    _isActive = t?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _thumbController.dispose();
    _youtubeIdController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text) ?? 0.0;

      final newTemplate = AdminTemplate(
        id: widget.template?.id ?? '',
        title: _titleController.text,
        description: _descController.text,
        thumbnailUrl: _thumbController.text,
        youtubeId: _youtubeIdController.text,
        category: _selectedCategory,
        price: price,
        viewCount: widget.template?.viewCount ?? 0,
        isActive: _isActive,
      );

      if (widget.template == null) {
        context.read<AdminBloc>().add(CreateTemplateEvent(newTemplate));
      } else {
        context.read<AdminBloc>().add(UpdateTemplateEvent(newTemplate));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.template == null ? "Create Template" : "Edit Template",
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField("Title", _titleController),
            _buildTextField("Description", _descController, maxLines: 3),
            _buildTextField("Thumbnail URL (Optional)", _thumbController),
            _buildTextField("YouTube ID", _youtubeIdController),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ),

            _buildTextField(
              "Price (₹)",
              _priceController,
              keyboardType: TextInputType.number,
            ),

            SwitchListTile(
              title: const Text(
                "Is Active",
                style: TextStyle(color: Colors.white),
              ),
              value: _isActive,
              activeThumbColor: Colors.greenAccent,
              onChanged: (val) => setState(() => _isActive = val),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submit,
              child: Text(widget.template == null ? "CREATE" : "UPDATE"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent),
          ),
        ),
        validator: (val) => val != null && val.isEmpty ? "Required" : null,
      ),
    );
  }
}
