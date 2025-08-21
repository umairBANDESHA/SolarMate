import '../../colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductEditPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String userEmail;
  final String productId;

  const ProductEditPage({
    super.key,
    required this.product,
    required this.userEmail,
    required this.productId,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  bool isSaving = false;
  bool isEditing = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.product['title'] ?? '',
    );
    _priceController = TextEditingController(
      text: (widget.product['price'] ?? 0.0).toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product['description'] ?? '',
    );
    _contactController = TextEditingController(
      text: widget.product['contact'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.product['address'] ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _updateProduct() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .collection('products')
          .doc(widget.productId)
          .update({
            'title': _titleController.text,
            'price': double.tryParse(_priceController.text) ?? 0.0,
            'description': _descriptionController.text,
            'contact': _contactController.text,
            'address': _addressController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Confirm Deletion',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
            content: const Text(
              'Are you sure you want to delete this product?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userEmail)
            .collection('products')
            .doc(widget.productId)
            .delete();

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product['images']?[0];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Product",
          style: TextStyle(color: AppColors.accentWhite),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.accentWhite),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.lock : Icons.edit),
            onPressed: () => setState(() => isEditing = !isEditing),
          ),
        ],
      ),
      backgroundColor: AppColors.lightGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            GestureDetector(
              onTap: isEditing ? _pickImage : null,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image:
                        _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (imageUrl != null
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage(
                                      'assets/placeholder.png',
                                    ))
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child:
                    isEditing
                        ? const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 20),

            // Form Fields
            _buildTextField(_titleController, "Title", enabled: isEditing),
            _buildTextField(
              _descriptionController,
              "Description",
              maxLines: 3,
              enabled: isEditing,
            ),
            _buildTextField(
              _priceController,
              "Price",
              prefixText: '\$ ',
              inputType: TextInputType.number,
              enabled: isEditing,
            ),
            _buildTextField(
              _contactController,
              "Contact Info",
              inputType: TextInputType.phone,
              enabled: isEditing,
            ),
            _buildTextField(_addressController, "Address", enabled: isEditing),
            const SizedBox(height: 24),

            if (isSaving)
              const Center(child: CircularProgressIndicator())
            else if (isEditing)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "SAVE CHANGES",
                        style: TextStyle(color: AppColors.accentWhite),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _deleteProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "DELETE PRODUCT",
                  style: TextStyle(color: AppColors.accentWhite, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
    String? prefixText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: AppColors.accentWhite,
          prefixText: prefixText,
        ),
      ),
    );
  }
}
